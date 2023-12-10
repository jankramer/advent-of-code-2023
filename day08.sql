create or replace table map as (
  select trim(#1) as src,
         regexp_extract_all(#2, '\w{3}') as dest
    from read_csv_auto('day08.input.csv', delim = '=')
);

create or replace table instr as (
   select unnest(range(len(#1))) as idx,
          case unnest(str_split(#1, ''))
            when 'L' then 1
            when 'R' then 2
          end as dir,
     from read_csv_auto('day08.input.csv', delim = '')
  qualify row_number() over() = 1
);


-- Part A
with recursive steps(src, n) as (
  select 'AAA', 0
   union all
  select map.dest[(select dir from instr where idx = n % (select count(*) from instr))], n + 1
    from steps
    join map on map.src = steps.src
   where steps.src != 'ZZZ'
)
select max(n) as part_a from steps;


-- Part B
create or replace function dir(src_in, n) as (select dest[(select dir from instr where idx = n % (select count(*) from instr))] from map where map.src = src_in);
create or replace table part_b_tmp as (
      with recursive steps(src, n) as (
             select src, 0
               from map
              where src[3] = 'A'
              union all
             select dir(src, n), n + 1
               from steps
              where n < 25000
           )
    select row_number() over (order by min(n)) as i,
           src,
           min(n) n
      from steps where src[3] = 'Z'
  group by src
  order by n
);

with recursive part_b(lcm, i) as (
  select cast(n as int64), 1 from part_b_tmp where #1 = 1
   union all
  select lcm(lcm, part_b_tmp.n),
         part_b.i + 1
    from part_b
    join part_b_tmp on part_b_tmp.i = part_b.i + 1
)
select max(lcm) as part_b from part_b;
