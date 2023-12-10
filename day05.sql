create or replace table input as (select #1 as line, row_number() over () as lineno from 'day05.input.csv');

create or replace table seeds as (
  select cast(unnest(regexp_extract_all(line, '(\d+) (\d+)', 1)) as int64) as a,
         cast(unnest(regexp_extract_all(line, '(\d+) (\d+)', 2)) as int64) as b,
    from input
   where lineno = 1
);

create or replace table maps as (
   with
    maps_flat as (
      select max(if(line is null, lineno, null)) over (order by lineno) as grp,
             try_cast(regexp_extract(line, '(\d+) \d+ \d+', 1) as int64) as dest_start,
             try_cast(regexp_extract(line, '\d+ (\d+) \d+', 1) as int64) as source_start,
             try_cast(regexp_extract(line, '\d+ \d+ (\d+)', 1) as int64) as range_length,
        from input
       where lineno > 1
    )

  select dense_rank() over (order by grp) as grp,
         array_agg({
            a: source_start,
            b: source_start + range_length - 1,
            delta: dest_start - source_start,
         } order by source_start) as maps
    from maps_flat
   where dest_start is not null
   group by grp
);

create or replace temp macro new_segments(a_in, b_in, maps) as table
    with
      maps as (select unnest(maps, recursive := 1)),

      points as (
          select a_in AS a_out
           union distinct
          select b_in + 1
           union distinct
          select maps.a as x from maps where maps.a between a_in and b_in
           union distinct
          select maps.b + 1 as x from maps where maps.b between a_in and b_in
        order by x
      ),

      segments as (
         select a_out,
                lead(a_out) over (order by a_out) - 1 as b_out
           from points
        qualify lead(a_out) over (order by a_out) is not null
      )

        select a_out + ifnull(delta, 0) as a_out,
               b_out + ifnull(delta, 0) as b_out,
          from segments
     left join maps on b_out >= maps.a and maps.b >= a_out
      order by a_out;

create or replace temp macro solve(segments) as table
    with
      recursive foo(a, b, grp) as (
        select unnest(segments, recursive := 1), 0

         union all

        select seg.a_out,
               seg.b_out,
               foo.grp + 1
          from foo
          join maps on maps.grp = foo.grp + 1
         cross join new_segments(foo.a, foo.b, maps.maps) AS seg
      )
      select min(a) AS answer from foo w where grp = 7;

select (select answer from solve((select flatten(array_agg([{a: a, b: a}, {a: b, b: b}])) from seeds))) as part_a,
       (select answer from solve((select array_agg({a: a, b: a + b - 1}) from seeds))) as part_b;
