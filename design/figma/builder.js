/* QuestWay. Run in a new Figma Design file using the development-plugin manifest. */
'use strict';

const BG = '#f7f1ea';
const SURFACE = '#fffaf4';
const INK = '#291b29';
const MUTED = '#665563';
const ACCENT = '#75406b';
const LINE = '#cdbdb1';
const paintCache = new Map();
const imageCache = new Map();
const fonts = {};

function colors(value) {
  if (value.startsWith('#')) {
    const v = value.slice(1);
    return [0, 2, 4].map(index => parseInt(v.slice(index, index + 2), 16) / 255).concat(1);
  }
  const parts = value.match(/[\d.]+/g)?.map(Number) || [];
  return parts.length >= 3 ? [parts[0] / 255, parts[1] / 255, parts[2] / 255, parts[3] ?? 1] : [0,0,0,0];
}

function paint(value) {
  if (!paintCache.has(value)) {
    const [r,g,b,opacity] = colors(value);
    paintCache.set(value, opacity ? [{type:'SOLID',color:{r,g,b},opacity}] : []);
  }
  return paintCache.get(value);
}

function attach(parent, node, x=0, y=0) {
  parent.appendChild(node);
  node.x = x;
  node.y = y;
  return node;
}

function rectangle(parent, name, box, fill, border, radius=0) {
  const node = attach(parent, figma.createRectangle(), box.x, box.y);
  node.name = name;
  node.resize(Math.max(.01,box.w), Math.max(.01,box.h));
  node.cornerRadius = Math.min(radius, box.w/2, box.h/2);
  node.fills = paint(fill);
  if (border) {
    node.strokes = paint(border);
    node.strokeAlign = 'INSIDE';
  }
  return node;
}

function text(parent, value, opts={}) {
  const {x=0,y=0,size=16,weight=400,fill=INK,tracking=0,width} = opts;
  const node = attach(parent, figma.createText(), x, y);
  node.name = value.slice(0,70);
  node.fontName = weight>=660 ? fonts.bold : fonts.regular;
  node.fontSize = size;
  node.letterSpacing = {unit:'PIXELS',value:tracking};
  node.fills = paint(fill);
  node.characters = value;
  if (width) {
    node.textAutoResize = 'HEIGHT';
    node.resize(Math.max(width,1),node.height);
  }
  return node;
}

function shape(parent, token, ox=0, oy=0) {
  const box={...token,x:token.x-ox,y:token.y-oy};
  if (token.kind==='text') {
    return text(parent,token.text,{x:box.x,y:box.y,size:token.size,weight:token.weight,
                                  fill:token.color,tracking:token.tracking});
  }
  if (token.kind==='rect') {
    const node=rectangle(parent,token.name,box,token.fill,token.border ? token.stroke : null,token.radius);
    if (token.border) node.strokeWeight=token.border;
    return node;
  }
  const asset = token.asset ? DATA.assets[token.asset] : null;
  if (token.kind==='vector' || asset?.svg) {
    const vector=attach(parent,figma.createNodeFromSvg(token.svg || asset.svg),box.x,box.y);
    vector.name=token.name;
    vector.resize(box.w,box.h);
    return vector;
  }
  if (!imageCache.has(token.asset)) {
    imageCache.set(token.asset,figma.createImage(figma.base64Decode(asset.bytes)).hash);
  }
  const node=rectangle(parent,token.name,box,'transparent',null,token.radius);
  node.fills=[{type:'IMAGE',scaleMode:'FILL',imageHash:imageCache.get(token.asset)}];
  if (token.shade) {
    const shade=rectangle(parent,'Затемнение под подписью',box,'transparent');
    shade.fills=[{type:'GRADIENT_LINEAR',gradientTransform:[[0,1,0],[-1,0,1]],gradientStops:[
      {position:0,color:{r:.04,g:.05,b:.08,a:0}},
      {position:1,color:{r:.04,g:.05,b:.08,a:.78}},
    ]}];
  }
  return node;
}

function auto(parent,name,axis,box,gap,padding=0) {
  const node=attach(parent,figma.createFrame(),box.x,box.y);
  node.name=name;
  node.resize(box.w,box.h);
  node.fills=[];
  node.clipsContent=false;
  node.layoutMode=axis;
  node.primaryAxisSizingMode='AUTO';
  node.counterAxisSizingMode='FIXED';
  node.itemSpacing=gap;
  node.paddingTop=node.paddingBottom=node.paddingLeft=node.paddingRight=padding;
  return node;
}

function content(frame,data) {
  const built = new Map();
  for (const token of data.tokens) {
    if (!token.row) {
      shape(frame,token);
      continue;
    }
    const [groupIndex,rowIndex]=token.row;
    const group=data.groups[groupIndex];
    const row=group.children[rowIndex];
    if (!built.has(group)) {
      const container=auto(frame,group.name,group.axis,group,group.gap);
      const rows=new Map();
      group.children.forEach(child => {
        const node=attach(container,figma.createFrame());
        node.name=child.name;
        node.resize(child.w,child.h);
        node.fills=[];
        node.clipsContent=false;
        if (group.axis==='VERTICAL') node.layoutSizingHorizontal='FILL';
        rows.set(child,node);
      });
      built.set(group,rows);
    }
    const layer=shape(built.get(group).get(row),token,row.x,row.y);
    if (token.kind==='rect' && Math.abs(token.w-row.w)<3) {
      layer.constraints={horizontal:'STRETCH',vertical:'MIN'};
    }
  }
}

function newScreen(page, data, x, y) {
  const screen=attach(page,figma.createFrame(),x,y);
  screen.name=data.name+' · '+Math.round(data.w)+'×'+Math.round(data.h);
  screen.resize(data.w,data.h);
  screen.fills=paint(BG);
  screen.clipsContent=true;
  screen.overflowDirection='VERTICAL';
  const mobile=data.device==='mobile';
  screen.layoutGrids=[{pattern:'COLUMNS',alignment:'STRETCH',gutterSize:mobile?8:16,
    count:mobile?4:12,offset:mobile?14:80,visible:false,color:{r:.46,g:.25,b:.42,a:.1}}];
  content(screen,data);
  return screen;
}

async function connect(node,destination,trigger={type:'ON_CLICK'},animated=false) {
  await node.setReactionsAsync([{trigger,actions:[{type:'NODE',destinationId:destination.id,
    navigation:'NAVIGATE',transition:animated ? {type:'DISSOLVE',easing:{type:'EASE_IN_AND_OUT'},duration:.4} : null,
    preserveScrollPosition:animated}]}]);
}

const pathKeys={'/':'home','/register/':'register','/login/':'login','/requests/':'requests',
  '/requests/new/':'create','/staff/':'admin'};
const submits={register:'login',login:'requests',create:'createFilled',
  createFilled:'requestsUpdated',status:'adminUpdated'};

function nextSlide(index) {
  return ['home','home2','home3','home4'][(index+4)%4];
}

async function flow(page,frames) {
  for (const [row,device] of ['desktop','mobile'].entries()) {
    const data=frames.filter(frame=>frame.device===device);
    const byKey={};
    let x=0;
    for (const item of data) {
      byKey[item.key]=newScreen(page,item,x,row*1240);
      x+=item.w+52;
    }
    for (const item of data) {
      const screen=byKey[item.key];
      const slide = item.key.startsWith('home') ? Number(item.key.slice(4)||'1')-1 : null;
      if (slide!==null) {
        await connect(screen,byKey[nextSlide(slide+1)],{type:'AFTER_TIMEOUT',timeout:3000},true);
      }
      for (const spot of item.hotspots) {
        const href=spot.to.split('?')[0];
        let key=pathKeys[href];
        if (href==='@submit') key=submits[item.key];
        if (/^\/staff\/\d+\/status\/$/.test(href)) key='status';
        if (slide!==null && href.startsWith('@step')) key=nextSlide(slide+Number(href.slice(5)));
        if (slide!==null && href.startsWith('@dot')) key=nextSlide(Number(href.slice(4)));
        if (!key || !byKey[key] || key===item.key) continue;
        const hit=rectangle(screen,spot.name,spot,'rgba(255,255,255,0.001)');
        await connect(hit,byKey[key],{type:'ON_CLICK'},href.startsWith('@step') || href.startsWith('@dot'));
      }
    }
    page.flowStartingPoints=[...page.flowStartingPoints,{nodeId:byKey.home.id,name:device==='mobile'?'Мобильный · 390×844':'Десктопный · 1440×1024'},
      {nodeId:byKey.admin.id,name:device==='mobile'?'Администратор · мобильный':'Администратор · десктопный'}];
  }
}

const STATES=['Обычное','Наведение','Нажатие','Неактивное','Ошибка'];
const COMPONENTS=[
  ['Кнопка','Забронировать'],['Поле ввода','12.11.2026'],['Выпадающий список','Стандартный  ▾'],
  ['Карточка квеста','Тайна заброшенного бункера'],['Статус','Подтверждено'],['Уведомление','Данные сохранены'],
];

function component(page, name, label, index, x, y) {
  const node=attach(page,figma.createComponent(),x,y);
  node.name='Состояние='+STATES[index];
  node.resize(172,48);
  node.cornerRadius=10;
  node.layoutMode='VERTICAL';
  node.counterAxisSizingMode='FIXED';
  node.primaryAxisSizingMode='AUTO';
  node.paddingTop=node.paddingBottom=10;
  node.paddingLeft=node.paddingRight=10;
  node.itemSpacing=4;
  const isButton=name==='Кнопка';
  const positive=name==='Статус' || name==='Уведомление';
  const error=index===4;
  node.fills=paint(error?'#ffeaee':isButton?(index===1||index===2?'#613158':ACCENT):positive?'#dff5e9':SURFACE);
  node.strokes=paint(error?'#bc3647':index===1||index===2?ACCENT:LINE);
  if (index===3) node.opacity=.48;
  if (index===2) node.strokeWeight=2;
  const message=error && positive ? (name==='Статус'?'Отменено':'Ошибка сохранения') : label;
  const labelNode=text(node,message,{size:14,weight:700,fill:error?'#a72b3d':isButton?'#ffffff':INK,width:152});
  labelNode.layoutSizingHorizontal='FILL';
  if (error && !positive) text(node,'Проверьте данные',{size:11,fill:'#a72b3d'});
  return node;
}

function kit(page) {
  text(page,'QuestWay / UI-кит',{x:0,y:0,size:44,weight:760});
  text(page,'Палитра, Inter, сетка, иконки и 30 вариантов компонентов',{x:0,y:61,size:17,fill:MUTED});
  [BG,SURFACE,INK,ACCENT,'#dff5e9','#ffeaee'].forEach((color,i)=>{
    rectangle(page,color,{x:i*146,y:104,w:132,h:63},color,LINE,9);
    text(page,color.toUpperCase(),{x:i*146,y:172,size:13,fill:MUTED});
    const style=figma.createPaintStyle();
    style.name='QuestWay / '+color.toUpperCase();
    style.paints=paint(color);
  });
  for (const [name,size,weight,x] of [['Заголовок',32,750,0],['Основной текст',16,400,250],['ПОДПИСЬ',11,700,440]]) {
    text(page,name,{x,y:215,size,weight});
    const style=figma.createTextStyle();
    style.name='QuestWay / '+name;
    style.fontSize=size;
    style.fontName=weight>=660?fonts.bold:fonts.regular;
  }
  text(page,'←    →    ✓    ×    +    ☰',{x:580,y:215,size:19,weight:700});
  text(page,'1440 × 1024 · 12 колонок      /      390 × 844 · 4 колонки',{x:0,y:276,size:15,weight:700});
  [12,4].forEach((count,row)=>{
    for(let i=0;i<count;i++) rectangle(page,'Колонка '+(i+1),{x:i*32,y:310+row*25,w:26,h:17},'#f2e2ef');
  });
  COMPONENTS.forEach(([name,label],group)=>{
    const y=395+group*142;
    text(page,name,{x:0,y,size:17,weight:700});
    const variants=STATES.map((_,index)=>component(page,name,label,index,index*184,y+27));
    const set=figma.combineAsVariants(variants,page);
    set.name=name+' / варианты';
  });
}

async function main() {
  const available=(await figma.listAvailableFontsAsync()).map(item=>item.fontName);
  const regular=available.find(font=>font.family==='Inter' && font.style==='Regular');
  fonts.regular=regular || available.find(font=>font.family==='Roboto' && font.style==='Regular');
  if (!fonts.regular) throw new Error('Установите Inter из репозитория и повторите импорт.');
  fonts.bold=available.find(font=>font.family===fonts.regular.family && font.style==='Bold') || fonts.regular;
  await Promise.all([figma.loadFontAsync(fonts.regular),figma.loadFontAsync(fonts.bold)]);
  const kitPage=figma.createPage();
  kitPage.name='01 · UI-кит';
  await kitPage.loadAsync();
  kit(kitPage);
  for (const [device,name] of [['mobile','02 · Мобильная версия'],['desktop','03 · Десктопная версия']]) {
    const page=figma.createPage();
    page.name=name;
    await page.loadAsync();
    const items=DATA.frames.filter(frame=>frame.device===device && ['home','register','login','requests','create','admin'].includes(frame.key));
    items.forEach((item,i)=>newScreen(page,item,i*(item.w+42),0));
  }
  const flowPage=figma.createPage();
  flowPage.name='04 · Прототип';
  await flowPage.loadAsync();
  await flow(flowPage,DATA.frames);
  await figma.setCurrentPageAsync(kitPage);
  figma.viewport.scrollAndZoomIntoView(kitPage.children);
}

main().then(()=>figma.closePlugin('QuestWay: 4 страницы готовы.')).catch(error=>{
  console.error(error);
  figma.closePlugin('Ошибка импорта QuestWay: '+error.message);
});
