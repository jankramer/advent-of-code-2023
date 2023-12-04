create or replace table cards as (
  with
    input as (select * from 'day04.input.csv'),
    parsed as (
      select regexp_extract_all(#1, '(\d+)+', 1) l,
             regexp_extract_all(#2, '(\d+)+', 1) r,
             cast(l[1] as int) as card_id,
             l[2:] as winning_numbers,
             r as own_numbers,

             len(list_intersect(winning_numbers, own_numbers)) matching_numbers,
             case matching_numbers
               when 0 then 0
               else 2**(matching_numbers-1)
             end score,
        from input
    )

  select card_id,
         score,
         card_id + matching_numbers as copy_until,
         1 as count
    from parsed
);

with recursive copies(card_id, score, copy_until, count, current_card_id) as (
    select *, 1 as current_card_id
      from cards

     union all

    select card_id,
           score,
           copy_until,
           count + if(
             card_id > current_card_id
               and card_id <= (select copy_until from cards where card_id = current_card_id),
               (select count from copies where card_id = current_card_id),
             0
           ),
           current_card_id + 1
      from copies
      where current_card_id <= (select max(card_id) - 1 from cards)
)

select (select sum(score) from cards) as part_a,
       (select sum(count) from copies where current_card_id = (select max(card_id) from cards)) as part_b;
