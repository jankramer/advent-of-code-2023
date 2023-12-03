with
  input as (select row_number() over () y, #1 as line from 'day03.input.csv'),

  grid as (
      select y,
             #3 as x,
             nullif(line[x], '.') as char,
             if(ascii(char) between 48 and 57, null, char) as symbol,
             if(ascii(char) between 48 and 57, char, null) as digit,
             line,
        from input,
             unnest(range(1, len(line) + 1)) as xs
  ),

  part_numbers as (
    select y,
           if(digit is not null and lead(digit) over (partition by y order by x) is null,
              max(if(x = 1 and line[x] != '.', 0, if(digit is null, x, null))) over part_number_window + 1,
              null) as x_start,
           x as x_end,
           cast(line[x_start:x_end] as int) as part_number,
           range(x_start - 1, x_end + 2) as adjacent_xs,
           range(y - 1, y + 2) as adjacent_ys,
      from grid
      window part_number_window as (partition by y order by x range between unbounded preceding and current row)
  ),

  adjacent_part_numbers AS (
    select grid.x as symbol_x,
           grid.y as symbol_y,
           part_number,
           symbol,
      from part_numbers p
      join grid on grid.symbol is not null and
           list_contains(adjacent_xs, grid.x) and
           list_contains(adjacent_ys, grid.y)
     where part_number is not null
  ),

  gear_ratios AS (
      select product(part_number)
        from adjacent_part_numbers
       where symbol = '*'
    group by symbol_x, symbol_y
      having count(*) = 2
)

select (select sum(part_number) from adjacent_part_numbers) as part_a,
       (select sum(#1) from gear_ratios) as part_b
