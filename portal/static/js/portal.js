'use strict';

function setError(control, text) {
  const field = control.closest('.field');
  const error = field?.querySelector('.field-error');
  if (!error) return;
  error.textContent = text;
  field.classList.toggle('has-error', Boolean(text));
  if (text) control.setAttribute('aria-invalid', 'true');
  else control.removeAttribute('aria-invalid');
}

function validateForm(form) {
  form.noValidate = true;
  form.addEventListener('input', event => {
    if (event.target.closest('.has-error')) setError(event.target, '');
  });
  form.addEventListener('submit', event => {
    let firstInvalid = null;
    for (const field of form.elements) {
      if (!field.willValidate) continue;
      const validity = field.validity;
      const text = validity.valueMissing ? 'Заполните это поле.' :
        !validity.valid ? (field.dataset.invalid || 'Проверьте значение поля.') : '';
      setError(field, text);
      if (text && !firstInvalid) firstInvalid = field;
    }
    if (firstInvalid) {
      event.preventDefault();
      firstInvalid.focus();
    }
  });
}

function phoneMask(input) {
  input.addEventListener('input', () => {
    const digits = input.value.replace(/\D/g, '');
    if (!digits) return;
    const number = (/^[78]/.test(digits) ? digits.slice(1) : digits).slice(0, 10);
    const space = document.body.classList.contains('theme-help') ? ' ' : '';
    let result = '8';
    if (number) result += '(' + number.slice(0, 3);
    if (number.length > 3) result += ')' + space + number.slice(3, 6);
    if (number.length > 6) result += '-' + number.slice(6, 8);
    if (number.length > 8) result += '-' + number.slice(8);
    input.value = result;
  });
}

function dateMask(input) {
  input.addEventListener('input', () => {
    const digits = input.value.replace(/\D/g, '').slice(0, 8);
    input.value = [digits.slice(0, 2), digits.slice(2, 4), digits.slice(4)].filter(Boolean).join('.');
  });
}

function setupAvailability(form) {
  const quest = form.elements.quest;
  const day = form.elements.day;
  const variation = form.elements.variation;
  const slot = form.elements.slot;
  const note = form.querySelector('[data-availability-note]');
  const replace = (select, items, hint, previous) => {
    select.replaceChildren(new Option(hint, ''), ...items.map(item => new Option(item.label, item.id)));
    if ([...select.options].some(option => option.value === previous)) select.value = previous;
  };
  let pending;
  async function refresh() {
    pending?.abort();
    const abort = new AbortController();
    pending = abort;
    const completeDay = /^\d{2}\.\d{2}\.\d{4}$/.test(day.value);
    const oldMode = variation.value;
    const oldSlot = slot.value;
    if (!quest.value) {
      replace(variation, [], 'Выберите вариацию');
      replace(slot, [], 'Выберите время');
      note.textContent = 'Выберите квест и введите дату, чтобы увидеть свободное время.';
      return;
    }
    const query = new URLSearchParams({quest: quest.value, day: completeDay ? day.value : ''});
    replace(slot, [], 'Загрузка…');
    try {
      const response = await fetch(form.dataset.availability + '?' + query, {signal:abort.signal});
      if (!response.ok) throw new Error('availability');
      const data = await response.json();
      replace(variation, data.variations, 'Выберите вариацию', oldMode);
      replace(slot, data.slots, 'Выберите время', oldSlot);
      note.textContent = !completeDay ? 'Введите дату проведения квеста.' :
        data.slots.length ? 'Показано только свободное время. Часовой пояс — Москва.' :
        'Свободных интервалов нет. Выберите другую дату.';
    } catch (error) {
      if (error.name !== 'AbortError') {
        replace(slot, [], 'Выберите время');
        note.textContent = 'Расписание недоступно. Измените дату или обновите страницу.';
      }
    }
  }
  quest.addEventListener('change', refresh);
  day.addEventListener('input', refresh);
  if (quest.value) refresh();
}

document.querySelectorAll('[data-validate]').forEach(validateForm);
document.querySelectorAll('[data-phone]').forEach(phoneMask);
document.querySelectorAll('[data-date]').forEach(dateMask);
document.querySelectorAll('[data-availability]').forEach(setupAvailability);
document.querySelectorAll('[data-dismiss]').forEach(button => {
  button.addEventListener('click', () => button.closest('.toast').remove());
});
const menu = document.querySelector('.menu-toggle');
menu?.addEventListener('click', () => {
  const navigation = document.getElementById(menu.getAttribute('aria-controls'));
  const open = navigation.classList.toggle('is-open');
  menu.setAttribute('aria-expanded', String(open));
  menu.setAttribute('aria-label', open ? 'Закрыть меню' : 'Открыть меню');
});

for (const dialog of document.querySelectorAll('[data-open-dialog]')) {
  dialog.addEventListener('cancel', event => {
    event.preventDefault();
    location.href = dialog.querySelector('.icon-button').href;
  });
  // Keep the underlying page legible and allow copying identifiers while editing.
  dialog.removeAttribute('open');
  dialog.show();
  dialog.classList.add('is-floating');
}
for (const form of document.querySelectorAll('[data-status-form]')) {
  const reason = form.elements.reason;
  if (!reason) continue;
  const sync = () => {
    reason.required = form.elements.status.value === 'cancelled';
    reason.closest('.field').hidden = !reason.required;
  };
  form.elements.status.addEventListener('change', sync);
  sync();
}
