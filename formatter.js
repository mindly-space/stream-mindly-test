export function compile(msgs) {
  const results = {};
  for (const [id, msg] of Object.entries(msgs)) {
    results[id] = msg.defaultMessage;
  }
  results['language.en'] = 'Англійська';
  results['language.uk'] = 'Українська';
  results['language.pl'] = 'Польска';
  results['language.ru'] = 'Російська';
  results['language.es']  = 'Іспанська'

  results['country.gb'] = 'Англія';
  results['country.ua'] = 'Україна';
  results['country.pl'] = 'Польща';

  results['general.numbers.one.1'] = 'один';
  results['general.numbers.one.2'] = 'два';
  results['general.numbers.one.3'] = 'три';
  results['general.numbers.one.4'] = 'чотири';
  results['general.numbers.one.5'] = 'п`ять';
  results['general.numbers.one.6'] = 'шість';
  results['general.numbers.one.7'] = 'сім';
  results['general.numbers.one.8'] = 'вісім';
  results['general.numbers.one.9'] = 'дев`ять';

  results['general.numbers.tens.2'] = 'двадцять';
  results['general.numbers.tens.3'] = 'тридцять';
  results['general.numbers.tens.4'] = 'сорок';
  results['general.numbers.tens.5'] = 'п`ятдесят';
  results['general.numbers.tens.6'] = 'шістдесят';
  results['general.numbers.tens.7'] = 'сімдесят';
  results['general.numbers.tens.8'] = 'вісімдесят';
  results['general.numbers.tens.9'] = 'дев`яносто';

  results['general.numbers.teens.0'] = 'десять';
  results['general.numbers.teens.1'] = 'одинадцять';
  results['general.numbers.teens.2'] = 'дванадцять';
  results['general.numbers.teens.3'] = 'тринадцять';
  results['general.numbers.teens.4'] = 'чотирнадцять';
  results['general.numbers.teens.5'] = 'п`ятнадцять';
  results['general.numbers.teens.6'] = 'шістнадцять';
  results['general.numbers.teens.7'] = 'сімнадцять';
  results['general.numbers.teens.8'] = 'вісімнадцять';
  results['general.numbers.teens.9'] = 'дев`ятнадцять';

  results['general.numbers.hundreds.0'] = 'сто';
  results['general.numbers.hundreds.1'] = 'двісті';
  results['general.numbers.hundreds.2'] = 'триста';
  results['general.numbers.hundreds.3'] = 'чотириста';
  results['general.numbers.hundreds.4'] = 'пятсот';
  results['general.numbers.hundreds.5'] = 'шістсот';
  results['general.numbers.hundreds.6'] = 'сімсот';
  results['general.numbers.hundreds.7'] = 'вісімсот';
  results['general.numbers.hundreds.8'] = 'девятсот';

  return results;
}
