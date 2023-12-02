with
  input as (select #1 as x from 'day02.input.csv'),

  games as (
    select cast(regexp_extract(x, 'Game (\d+)', 1) as int) as id,
           coalesce(cast(nullif(regexp_extract(#2, '(\d+) red', 1), '') as int), 0) as red,
           coalesce(cast(nullif(regexp_extract(#2, '(\d+) green', 1), '') as int), 0) as green,
           coalesce(cast(nullif(regexp_extract(#2, '(\d+) blue', 1), '') as int), 0) as blue,
           red <= 12 and green <= 13 and blue <= 14 as possible,
      from input,
           unnest(str_split(str_split(x, ':')[2], ';'))
  ),

  part_a as (select id from games group by id having bool_and(possible)),

  part_b as (
      select id,
             max(red) as red,
             max(green) as green,
             max(blue) as blue,
        from games
    group by id
  )

select (select sum(id) from part_a) as part_a,
       (select sum(red * green * blue) from part_b) as part_b,
