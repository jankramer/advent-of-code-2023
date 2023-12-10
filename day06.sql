create table input as (
  select #1 as key,
         [cast(x as int) for x in regexp_extract_all(#2, '(\d+)', 1)] as values,
    from read_csv_auto('day06.input.csv', delim = ':')
);

create or replace table races as (
  select unnest((select values from input where key = 'Time')) t,
         unnest((select values from input where key = 'Distance')) s
);

create macro solve(t, s) as (
    select (ceil(((-1 * t - sqrt(t * t - 4 * s)) / -2)) - 1)
           - (floor(((-1 * t + sqrt(t * t - 4 * s)) / -2)))
);

select (select product(solve(t, s)) from races) as part_a,
       (select solve(
                 cast(string_agg(t, '') as int64),
                 cast(string_agg(s, '') as int64)
               )
          from races
       ) as part_b
;
