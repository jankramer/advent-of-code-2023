create macro if not exists filter_digits(x) as regexp_replace(x, '[^\d]', '', 'g');
create macro if not exists calibration_value(x) as cast(x[1] || x[-1] as int);
create macro if not exists replace_digits(x) as
  replace(replace(replace(replace(replace(replace(replace(replace(replace(
    x, 'one', 'one1one'),
    'two', 'two2two'),
    'three', 'three3three'),
    'four', 'four4four'),
    'five', 'five5five'),
    'six', 'six6six'),
    'seven', 'seven7seven'),
    'eight', 'eight8eight'),
    'nine', 'nine9nine'
  );

  with lines as (select #1 as line from 'day01.input.csv')
select sum(calibration_value(filter_digits(line))) as part_a,
       sum(calibration_value(filter_digits(replace_digits(line)))) as part_b
  from lines;
