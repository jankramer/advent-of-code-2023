create table input as select #1 as hand, #2 as bid from read_csv_auto('day07.input.csv', delim = ' ');

create function card_rank_a(card) as printf('%X', position(card in '23456789TJQKA'));
create function card_rank_b(card) as printf('%X', position(card in 'J23456789TQKA'));

create function hand_type(hand) as (
        with cards as (select unnest(str_split(hand, '')) as card),
             scores as (
               select card,
                      count(*) n,
                      case
                        when n = 1 then 1
                        when n = 2 and lead(n) over (order by n desc) = 2 then 3
                        when n = 2 then 2
                        when n = 3 and lead(n) over (order by n desc) = 2 then 5
                        when n = 3 then 4
                        when n = 4 then 6
                        when n = 5 then 7
                      end t,
                 from cards
             group by card
             order by n desc
        )
        select max(t) from scores
);

create function joker(hand) as (
       with counts as (
                select #1 as card,
                       count(*) cnt
                  from unnest(str_split(hand, '')) c
              group by #1
            )
     select card
       from counts
      where card != 'J'
   order by cnt desc, card_rank_b(card) desc
      limit 1
);

create function hand_rank_a(hand) as hand_type(hand) || array_to_string([card_rank_a(x) for x in str_split(hand, '')], '');
create function hand_rank_b(hand_old, hand_new) as hand_type(hand_new) || array_to_string([card_rank_b(x) for x in str_split(hand_old, '')], '');

with
  part_a as (
    select *,
           rank() over (order by hand_rank_a(hand)) as rank
      from input
  ),

  part_b_tmp as (
    select *,
           if(hand = 'JJJJJ', 'JJJJJ', replace(hand, 'J', joker(hand))) as hand_new,
      from input
  ),

  part_b as (
    select *,
           rank() over (order by hand_rank_b(hand, hand_new)) as rank
      from part_b_tmp
  )

select (select sum(bid * rank) from part_a) as part_a,
       (select sum(bid * rank) from part_b) as part_b
