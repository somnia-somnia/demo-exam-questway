"""Render a readable ER diagram from metadata exported by SQLite."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

BASE = Path(__file__).resolve().parents[1]
PIL_BG = '#eff4f8'
INK = '#14283a'
ACCENT = '#147d74'
MUTED = '#51687a'
LINE = '#c9d9e4'
font_file = BASE/'portal/static/fonts/Inter.ttf'


def font(size, weight=450):
    face = ImageFont.truetype(str(font_file), size)
    axes = face.get_variation_axes()
    face.set_variation_by_axes([weight if axis['name']==b'Weight' else axis['default'] for axis in axes])
    return face


def render():
    data = {row['name'].split('_',1)[1]:row for row in json.loads((BASE/'schema.json').read_text(encoding='utf8'))}
    quest = 'quest' in data
    width, height = (1590,910) if quest else (1440,590)
    im = Image.new('RGB',(width,height),PIL_BG)
    d = ImageDraw.Draw(im)
    brand = ('QuestWay' if quest else 'СлужбаПоддержки' if any(f['name']=='topic' for f in data['submission']['fields']) else 'Ключ.на.старт')
    d.text((40,29),'ЛОГИЧЕСКАЯ МОДЕЛЬ   /   SQLITE',font=font(17,760),fill=ACCENT)
    d.text((40,57),f'{brand} · ER-диаграмма',font=font(41,760),fill=INK)
    d.text((41,117),'PK — первичный ключ     FK — внешний ключ     UQ — уникальность     0..1 — необязательная связь',font=font(17),fill=MUTED)
    if quest:
        d.text((41,145),'На интервал — до одной неотменённой записи. Отменённые бронирования сохраняются в истории.',font=font(15),fill=MUTED)
    positions = {'member':(40,207),'submission':(530 if quest else 510,207),'review':(1095 if quest else 1010,207)}
    if quest:
        positions.update({'quest':(40,635),'slot':(530,635),'variation':(1095,635)})
    rects = {}
    for name,(x,y) in positions.items():
        size = 390
        rects[name] = (x,y,x+size,y+56+32*len(data[name]['fields'])+12)

    def path(points, left, right, offset=(0,-29)):
        d.line(points,fill=ACCENT,width=3,joint='curve')
        for x,y in (points[0],points[-1]):
            d.ellipse((x-5,y-5,x+5,y+5),fill=ACCENT)
        x0,y0=points[0]; x1,y1=points[-1]
        d.text((x0+offset[0],y0+offset[1]),left,font=font(14,710),fill=ACCENT,anchor='lt')
        d.text((x1+offset[0],y1+offset[1]),right,font=font(14,710),fill=ACCENT,anchor='rt')

    x = rects
    path([(x['member'][2],260),(x['submission'][0],260)],'1','0..N')
    path([(x['submission'][2],300),(x['review'][0],300)],'1','0..1')
    if quest:
        path([(x['quest'][2],699),(x['slot'][0],699)],'1','0..N')
        path([(x['quest'][2],755),(468,755),(468,845),(1055,845),(1055,762),(x['variation'][0],762)],'1','0..N')
        path([(727,x['submission'][3]),(727,x['slot'][1])],'0..N','',(38,6))
        d.text((741,610),'1',font=font(14,710),fill=ACCENT)
        path([(x['submission'][2],471),(1004,471),(1004,676),(x['variation'][0],676)],'0..N','1',(0,-29))

    for name, (x0,y0,x1,y1) in rects.items():
        d.rounded_rectangle((x0,y0,x1,y1),radius=15,fill='white',outline=LINE,width=2)
        d.rounded_rectangle((x0+1,y0+1,x1-1,y0+46),radius=14,fill='#dceeea')
        d.rectangle((x0+1,y0+27,x1-1,y0+47),fill='#dceeea')
        d.text((x0+15,y0+12),f'portal_{name}',font=font(21,760),fill=INK)
        foreign = {ref['from'] for ref in data[name]['refs']}
        for i,col in enumerate(data[name]['fields']):
            row_y = y0+54+32*i
            unique = col['name']=='login' or (name=='quest' and col['name']=='name')
            key = 'PK' if col['pk'] else 'FK' if col['name'] in foreign else 'UQ' if unique else ''
            if name=='review' and key=='FK':
                key = 'FK/UQ'
            d.text((x0+15,row_y),key,font=font(13,720),fill=ACCENT)
            d.text((x0+75,row_y),col['name'],font=font(17,580),fill=INK)
            d.text((x1-12,row_y),col['type'].upper(),font=font(13),fill=MUTED,anchor='rt')
            d.line((x0+14,row_y+24,x1-14,row_y+24),fill='#edf2f5')
    im.save(BASE/'er_diagram.png')


if __name__ == '__main__':
    render()
