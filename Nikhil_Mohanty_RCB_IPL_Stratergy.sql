use ipl;
-- --Objective -- --

-- 1. 

SELECT COLUMN_NAME, DATA_TYPE
FROM information_schema.Columns
WHERE TABLE_NAME = 'ball_by_ball'
AND TABLE_SCHEMA = 'ipl';
  
-- 2.
-- -- -- -- Runs scored in season 1 -- -- -- --
select sum(runs_scored) + sum(e.extra_runs) as total_runs_season1_RCB from ball_by_ball bb 
join batsman_scored ba on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id left join extra_runs e on bb.match_id = e.match_id and bb.over_id = e.over_id and bb.ball_id = e.ball_id and bb.innings_No = e.innings_no 
where Team_batting = 2 and season_id = 1;

-- -- -- -- Run scored by seasons -- -- -- --
select season_id, sum(runs_scored) as total_runs_RCB from ball_by_ball bb 
join batsman_scored ba on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id left join extra_runs e on bb.match_id = e.match_id and bb.over_id = e.over_id and bb.ball_id = e.ball_id and bb.innings_No = e.innings_no 
where Team_batting = 2 
group by season_id
order by season_id asc


-- 3
with cte1 as 
(
select Match_Id, season_year from matches m join season s on m.season_id = s.season_id where m.season_id = 2
),
cte2 as
(
select distinct p.player_id, (cte1.season_year-Year(pl.DOB)) as age  
from cte1 join matches m join player_match p on m.match_id = p.match_id join player pl on p.player_id = pl.player_id
)
select count(*) as player_count from cte2 where age > 25;

-- 4
select count(*) as matches_won from matches
where match_winner = 2 and season_id = 1;

-- 5
with last4season as 
(
select season_id from season order by season_id desc limit 4
)
select striker,player_name, round(100*(sum(runs_scored)/count(b.ball_id)),2) as strike_rate
from ball_by_ball b join batsman_scored s on b.match_id = s.match_id and b.over_id = s.over_id and b.ball_id = s.ball_id and b.innings_No = s.innings_no
join matches m on b.match_id = m.match_id join player p on b.striker = p.player_id
where m.season_id in (select * from last4season)
group by striker
order by strike_rate desc
limit 10;


-- 6
select striker as player_id,player_name, sum(runs_scored)/(select count(*) from season) as runs_scored
from ball_by_ball b join batsman_scored s on b.match_id = s.match_id and b.over_id = s.over_id and b.ball_id = s.ball_id and b.innings_No = s.innings_no
join matches m on b.match_id = m.match_id join player p on b.striker = p.player_id
group by striker
order by runs_scored desc;

-- 7
select bowler,player_name, round(count(*)/(select count(*) from season)) as avg_wickets_taken 
from ball_by_ball b join wicket_taken w on  b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no
join player p on b.bowler = p.player_id
group by bowler
order by avg_wickets_taken desc;

-- 8
-- -- For players having more than the avg runs
with cte1 as (
select striker as player_id,player_name, sum(runs_scored)/(select count(*) from season) as runs_scored
from ball_by_ball b join batsman_scored s on b.match_id = s.match_id and b.over_id = s.over_id and b.ball_id = s.ball_id and b.innings_No = s.innings_no
join matches m on b.match_id = m.match_id join player p on b.striker = p.player_id
group by striker
)
select player_id,player_name, runs_scored as avg_runs_scored
from cte1
where runs_scored > (select avg(runs_scored) from cte1)
order by runs_scored desc;

-- -- For players having more than the avg no of wickets

with cte1 as (
select bowler,player_name, round(count(*)/(select count(*) from season)) as avg_wickets_taken 
from ball_by_ball b join wicket_taken w on  b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no
join player p on b.bowler = p.player_id
group by bowler
order by avg_wickets_taken desc
)
select bowler as player_id,player_name, avg_wickets_taken
from cte1
where avg_wickets_taken > (select avg(avg_wickets_taken) from cte1);

-- 9

WITH cte1 AS (SELECT venue_id,count(match_winner) AS Wins FROM matches 
WHERE match_winner=2 
GROUP BY venue_id
),

cte2 AS (SELECT Venue_Id,count(Match_Winner) AS Lost FROM matches
WHERE (team_1=2 or team_2=2) AND match_winner<>2 AND match_winner is not null
GROUP BY venue_id),
cte3 AS (SELECT venue_id,venue_name FROM venue)

SELECT cte1.venue_id,venue_name,Wins,Lost FROM cte1
JOIN cte2
ON cte1.venue_id=cte2.venue_id
JOIN cte3 
ON cte2.venue_id=cte3.venue_id
ORDER BY   venue_id ASC;

CREATE TABLE IF NOT EXISTS rcb_record (
	venue_id integer NOT NULL primary key,
	venue_name varchar(200) NOT NULL,
	Wins integer ,
	Lost integer
);
INSERT INTO rcb_record VALUES (1,'M Chinnaswamy Stadium',29,25);
INSERT INTO rcb_record VALUES (2,'Punjab Cricket Association Stadium, Mohali',2,3);
INSERT INTO rcb_record VALUES (3,'Feroz Shah Kotla',4,2);
INSERT INTO rcb_record VALUES (4,'Wankhede Stadium',3,4);
INSERT INTO rcb_record VALUES (5,'Eden Gardens',3,4);
INSERT INTO rcb_record VALUES (6,'Sawai Mansingh Stadium',3,2);
INSERT INTO rcb_record VALUES (7,'Rajiv Gandhi International Stadium, Uppal',2,5);
INSERT INTO rcb_record VALUES (8,'MA Chidambaram Stadium, Chepauk',2,6);
INSERT INTO rcb_record VALUES (9,'Dr DY Patil Sports Academy',1,1);
INSERT INTO rcb_record VALUES (10,'Newlands',1,1);
INSERT INTO rcb_record VALUES (12,'Kingsmead',3,1);
INSERT INTO rcb_record VALUES (13,'SuperSport Park',2,1);
INSERT INTO rcb_record VALUES (15,'New Wanderers Stadium',3,1);
INSERT INTO rcb_record VALUES (28,'JSCA International Stadium Complex',1,2);
INSERT INTO rcb_record VALUES (30,'Sharjah Cricket Stadium',1,1);
INSERT INTO rcb_record VALUES (31,'Dubai International Cricket Stadium',1,1);

select * from rcb_record;

-- 10
with bowling_act as (
select player_id, player_name, Bowling_style.bowling_skill as bowling_stylee from player join bowling_style on player.bowling_skill = bowling_style.Bowling_id
),
ovr_bowled as 
(select bowling_stylee, COUNT(DISTINCT CONCAT(w.Match_Id, '_', w.Over_Id)) as overs_bowled
from wicket_taken w join ball_by_ball b on b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no 
join bowling_act a on Bowler = a.player_id 
group by bowling_stylee
),
wkts_taken as

(select bowling_stylee, count(*) as wickets_taken
from wicket_taken w join ball_by_ball b on b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no 
join bowling_act a on Bowler = a.player_id 
group by bowling_stylee
)
select w.bowling_stylee, wickets_taken, overs_bowled from ovr_bowled o join wkts_taken w on o.bowling_stylee = w.bowling_stylee
order by wickets_taken desc, overs_bowled asc;

-- 11
-- ----------- For batting ------
with season_runs as 
(select m.season_id, sum(runs_scored) as runs
from ball_by_ball b left join batsman_scored s on  b.match_id = s.match_id and b.over_id = s.over_id and b.ball_id =s.ball_id and b.innings_No = s.innings_no
left join matches m on b.match_id = m.match_id
where team_batting = (select team_id from team where team_name = 'Royal Challengers Bangalore')
group by m.season_id
)

select season_id, runs , lag(runs) over(order by season_id) as previous_runs ,
		   CASE 
           WHEN LAG(runs) OVER (ORDER BY season_id) IS NULL THEN 'First Season'
           ELSE ROUND(((runs - LAG(runs) OVER (ORDER BY season_id)) / LAG(runs) OVER (ORDER BY season_id)) * 100, 2)
       END AS percentage_diff
from season_runs ;
-- -------- For bowling---
with season_bowling as 
(select season_id, count(*) as wckts_taken
from ball_by_ball b join wicket_taken w on  b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no
left join matches m on b.match_id = m.match_id
where team_batting = (select team_id from team where team_name = 'Royal Challengers Bangalore')
group by m.season_id
)

select season_id, wckts_taken, lag(wckts_taken) over(order by season_id) as previous_wickets,
		   CASE 
           WHEN LAG(wckts_taken) OVER (ORDER BY season_id) IS NULL THEN 'First Season'
           ELSE ROUND(((wckts_taken - LAG(wckts_taken) OVER (ORDER BY season_id)) / LAG(wckts_taken) OVER (ORDER BY season_id)) * 100, 2)
       END AS percentage_diff 
from season_bowling ;


-- 12
-- -- Average runs per match -- --
select  (sum(runs_scored)+ sum(extra_runs))/count(distinct m.match_id) as avg_runs_per_match
from ball_by_ball b left join batsman_scored s on  b.match_id = s.match_id and b.over_id = s.over_id and b.ball_id =s.ball_id and b.innings_No = s.innings_no
left join extra_runs e on b.match_id = e.match_id and b.over_id = e.over_id and b.ball_id =e.ball_id and b.innings_No = e.innings_no
left join matches m on b.match_id = m.match_id
where team_batting = (select team_id from team where team_name = 'Royal Challengers Bangalore');

-- -- Average wickets per match -- --
select count(*)/count(distinct m.match_id) as wckts_taken_per_match
from ball_by_ball b join wicket_taken w on  b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no
left join matches m on b.match_id = m.match_id
where team_batting = (select team_id from team where team_name = 'Royal Challengers Bangalore');



-- 13
WITH cte1 AS (SELECT count(match_id) AS cnm,match_id FROM wicket_taken
              GROUP BY match_id),

cte2 AS (SELECT match_id,team_bowling,bowler FROM ball_by_ball
         WHERE team_bowling=2 ),

cte3 AS (SELECT match_id,player_id,team_id FROM player_match
         WHERE team_id=2),
cte4 AS (SELECT player_id,player_name FROM player 
		 WHERE bowling_skill is not null ),
cte5 AS (SELECT match_id,venue_id FROM matches),
cte6 AS (SELECT venue_id,venue_name FROM venue)
SELECT player_name,bowler,cte5.venue_id,venue_name,round(avg(cnm),2) AS avg_wicket,
DENSE_RANK()OVER(PARTITION BY cte5.venue_id
 ORDER BY avg(cnm) DESC ) AS bowler_Rank FROM cte1
JOIN cte2 
ON cte1.match_id=cte2.match_id
JOIN cte3
ON cte2.match_id=cte3.match_id
JOIN cte4
ON cte2.bowler=cte4.player_id
JOIN cte5
ON cte3.match_id=cte5.match_id
JOIN cte6
ON cte5.venue_id=cte6.venue_id
GROUP BY player_name,bowler,venue_id,venue_name
ORDER BY venue_id ASC;

-- 14
-- -- -- -- -- Batting Performance -- -- -- --
with striker_seasonal_score as (
select Striker, season_id, sum(runs_scored) as total_runs from ball_by_ball bb 
join batsman_scored ba 
on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id
where Team_batting = 2
group by Striker, season_id
),
RCB_Batsman_score as 
(
select  season_id, Striker as player_id,Player_name, total_runs from striker_seasonal_score sc join player p on sc.striker = p.player_id
order by Player_id asc,season_id asc, total_runs desc
)

select * from RCB_Batsman_score where season_id in (7,8,9);





-- 15
WITH cte1 AS (SELECT  distinct striker,match_id,team_batting,innings_no FROM ball_by_ball
WHERE Team_Batting=2),

cte2 AS (SELECT match_id,avg(runs_scored) AS total_score,innings_no FROM batsman_scored
GROUP BY match_id,innings_no),

cte3 AS (SELECT match_id,team_id,Player_Id FROM player_match
WHERE team_id=2),

cte4 AS (SELECT player_id,player_name FROM player),
cte5 AS (SELECT match_id,season_id,venue_id FROM matches),
cte6 AS (SELECT venue_id,venue_name FROM venue)
SELECT distinct striker,player_name,cte5.venue_id,venue_name,round(sum(total_score)) AS avg_runs_scored FROM cte1
JOIN cte2
ON cte1.match_id=cte2.match_id
JOIN cte3
ON cte1.striker=cte3.player_id
JOIN cte4 
ON cte3.player_id=cte4.player_id
JOIN cte5 
ON cte3.match_id=cte5.match_id
JOIN cte6
ON cte5.venue_id=cte6.venue_id
GROUP BY striker,player_name,cte5.venue_id,venue_name;







-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- SUBJECTIVE QUESTIONS -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- 1: How does toss decision have affected the result of the match ? (which visualisations could be used to better present your answer) And is the impact limited to only specific venues?



select SUM(CASE 
        WHEN toss_winner = match_winner THEN 1 
        ELSE 0 
    END) AS Match_won_by_toss_winner, SUM(CASE 
        WHEN toss_winner <> match_winner THEN 1 
        ELSE 0 
    END) AS Match_won_by_toss_loser
    
from matches;
-- -- -- -- --
select venue_name, 
SUM(CASE 
        WHEN toss_winner = match_winner THEN 1 
        ELSE 0 
    END) AS Match_won_by_toss_winner,
    SUM(CASE 
        WHEN toss_winner <> match_winner THEN 1 
        ELSE 0 
    END) AS Match_won_by_toss_loser,
    SUM(CASE 
        WHEN Outcome_type = 2 THEN 1 
        ELSE 0 
    END) AS No_result
from matches join venue on matches.venue_id = venue.venue_id
group by venue_name;
-- -- --


-- 2: Suggest some of the players who would be best fit for the team?
-- -- -- -- -- --
select Striker as player_id,player_name, sum(runs_scored)/count(distinct m.match_id) as avg_runs, round(100*(sum(runs_scored)/count(bb.ball_id)),2) as strike_rate from ball_by_ball bb
join batsman_scored ba 
on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id
join player p on bb.striker = p.player_id
where season_id in (8,9) and (year(m.match_date) - year(p.DOB)) <= 27
group by Striker, player_name
order by avg_runs desc, strike_rate desc 
limit 10;
-- -- -- -- -- --
with wckts as (
select Bowler as player_id,player_name, count(*) as wckts_taken
from ball_by_ball b join wicket_taken w on  b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no
left join matches m on b.match_id = m.match_id
join player p on b.bowler = p.player_id
where season_id in (8,9)  and (year(m.match_date) - year(p.DOB)) <= 27
group by Bowler
order by wckts_taken desc
),
bowling_average as 
(
select Bowler as player_id,player_name, sum(runs_scored)/count(distinct CONCAT(bb.Match_Id, '_', bb.Over_Id)) as Bowling_average from ball_by_ball bb
join batsman_scored ba 
on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id
join player p on bb.bowler = p.player_id
where season_id in (8,9)  and (year(m.match_date) - year(p.DOB)) <= 27
group by Bowler, player_name
order by Bowling_average asc
)
select w.player_id, w.player_name, wckts_taken, Bowling_average from wckts w join bowling_average bow on w.player_id = bow.player_id 
order by wckts_taken desc,Bowling_average asc limit 10;

-- 4: Which players offer versatility in their skills and can contribute effectively with both bat and ball? (can you visualize the data for the same)
with batsman as (
select Striker as player_id,player_name, sum(runs_scored)/count(distinct m.match_id) as avg_runs from ball_by_ball bb 
join batsman_scored ba 
on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id
join player p on bb.striker = p.player_id
group by Striker, player_name
order by avg_runs desc
),
bowler as (
select Bowler as player_id,player_name, count(*)/count(distinct bb.match_id) as avg_wcts from ball_by_ball bb join wicket_taken wt 
on bb.match_id = wt.match_id and bb.over_id = wt.over_id and bb.ball_id = wt.ball_id and bb.innings_No = wt.innings_no 
join player p on bb.Bowler = p.player_id
group by Bowler,p.Player_name
order by avg_wcts desc
)

select ba.player_id, ba.player_name , avg_runs,avg_wcts  from batsman ba join bowler bo on ba.player_id = bo.player_id
where avg_runs > (select avg(avg_runs) from batsman)
 and avg_wcts > (select avg(avg_wcts) from bowler)
order by  avg_runs desc,avg_wcts desc;


-- 5: Are there players whose presence positively influences the morale and performance of the team? (justify your answer using visualisation)
with rcb_won_matches_in_season_789 as (
select * from matches 
where Match_Winner=(select Team_Id from team where Team_Name='Royal Challengers Bangalore')
and Season_Id in (7,8,9) and
(Team_1=(select Team_Id from team where Team_Name='Royal Challengers Bangalore')
or Team_2= (select Team_Id from team where Team_Name='Royal Challengers Bangalore') )
),

balls_vk_abd as (
select bl.* from 
ball_by_ball bl join rcb_won_matches_in_season_789 rw 
on bl.Match_Id=rw.Match_Id 
where bl.Striker in (select Player_Id from player where Player_Name in ('V Kohli','AB de Villiers') )
), 

runs as (
select bv.* ,ba.runs_scored from 
balls_vk_abd bv join batsman_scored ba 
on bv.Match_Id=ba.Match_Id and 
bv.Over_Id=ba.Over_Id and 
bv.Ball_Id=ba.Ball_Id and 
bv.Innings_No=ba.Innings_No 
),

matches_runs as (
select pl.Player_Name, count(distinct ru.Match_Id) as total_matches,sum(ru.runs_scored) as total_runs 
from runs ru join player pl 
on ru.Striker=pl.Player_Id 
group by pl.Player_Name
)

select Player_Name,(total_runs/total_matches) as average_runs_scored_in_winning_matches
from matches_runs;
















-- 8: Analyze the impact of home ground advantage on team performance and identify strategies to maximize this advantage for RCB.
with home_win as (
select Team_1,count(Match_Id) as total_home_matches,sum( CASE WHEN Match_Winner=Team_1 then 1 else 0 end ) as wins
from matches
group by Team_1 
)
select t.Team_Name,((h.wins/h.total_home_matches)*100) as home_win_percentage
from home_win h join team t 
on h.Team_1=t.Team_Id
order by home_win_percentage desc;


-- 9: Come up with a visual and analytical analysis with the RCB past seasons performance and potential reasons for them not winning a trophy.
-- ------
select season_id, count(distinct match_id) as matches_played_by_RCB,
sum(CASE 
when Match_winner = 2 then 1
end) as Matches_won,
sum(CASE 
when Match_winner <> 2 then 1
end) as Matches_lost,
round(100*(sum(CASE 
when Match_winner = 2 then 1
end)/count(distinct match_id)),2) as win_Percentage 
 from matches 
where Team_1 = (select team_id from team where team_name = 'Royal Challengers Bangalore') 
or Team_2 = (select team_id from team where team_name = 'Royal Challengers Bangalore')
group by season_id;

-- ------ bowling economy in death overs
with over_death as (
select bl.Ball_Id,ba.runs_scored 
from ball_by_ball bl join batsman_scored ba
on bl.Match_Id=ba.Match_Id
and bl.Over_Id=ba.Over_Id
and bl.Ball_Id=ba.Ball_Id
and bl.Innings_No=ba.Innings_No
where bl.Team_Bowling=(select Team_Id from team where Team_Name='Royal Challengers Bangalore')
and bl.Over_Id in (16,17,18,19,20) 
) ,

balls_runs as (
select count(Ball_Id)  as total_balls,sum(runs_scored) as runs_given 
from over_death
)
select (runs_given/(total_balls/6)) as economy_in_death_overs
from balls_runs;

-- -- -- -- Average scores by middle order batting position

with batting_position as (
select bl.*,ba.runs_scored 
from ball_by_ball bl join batsman_scored ba
on bl.Match_Id=ba.Match_Id
and bl.Over_Id=ba.Over_Id
and bl.Ball_Id=ba.Ball_Id
and bl.Innings_No=ba.Innings_No
where bl.Team_Batting=(select Team_Id from team where Team_Name='Royal Challengers Bangalore')
and bl.Striker_Batting_Position in (5,6,7) 
),

matches_runs as (
select Striker_Batting_Position ,count(distinct Match_Id) as total_matches,sum(runs_scored) as total_runs 
from batting_position 
group by Striker_Batting_Position 
)

select Striker_Batting_Position , (total_runs/total_matches) as average 
from matches_runs ;

-- -- -- -- Average runs by top order batsman -- --- --- - -

with batting_position as (
select bl.*,ba.runs_scored 
from ball_by_ball bl join batsman_scored ba
on bl.Match_Id=ba.Match_Id
and bl.Over_Id=ba.Over_Id
and bl.Ball_Id=ba.Ball_Id
and bl.Innings_No=ba.Innings_No
where bl.Team_Batting=(select Team_Id from team where Team_Name='Royal Challengers Bangalore')
and bl.Striker_Batting_Position in (1,2,3,4) 
),

matches_runs as (
select Striker_Batting_Position ,count(distinct Match_Id) as total_matches,sum(runs_scored) as total_runs 
from batting_position 
group by Striker_Batting_Position 
)

select Striker_Batting_Position , (total_runs/total_matches) as average 
from matches_runs ;

-- -- -- -- Runs scored by virat, AB & Chris Gayle -- -- -- --
select player_name, sum(runs_scored)/count(distinct m.match_id) as avg_runs, round(100*(sum(runs_scored)/count(bb.ball_id)),2) as strike_rate from ball_by_ball bb 
join batsman_scored ba 
on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id
join player p on bb.striker = p.player_id
where bb.team_batting = (select Team_Id from team where Team_Name='Royal Challengers Bangalore') 
group by player_name
having player_name = 'AB de Villiers'or player_name ='CH Gayle' or player_name ='V Kohli'
order by avg_runs desc;

-- -- -- -- Wickets taken and bowling_average of yuzvendra Chahal, Dale styen, Chris Woakes
with wckts as (
select player_name, count(*) as wckts_taken
from ball_by_ball b join wicket_taken w on  b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no
left join matches m on b.match_id = m.match_id
join player p on b.bowler = p.player_id
where b.team_bowling = (select Team_Id from team where Team_Name='Royal Challengers Bangalore') 
group by player_name
having player_name = 'YS Chahal'or player_name ='DW Steyn'
order by wckts_taken desc
),
bowling_average as 
(
select player_name, sum(runs_scored)/count(distinct CONCAT(bb.Match_Id, '_', bb.Over_Id)) as Bowling_average from ball_by_ball bb
join batsman_scored ba 
on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id
join player p on bb.bowler = p.player_id
where bb.team_bowling = (select Team_Id from team where Team_Name='Royal Challengers Bangalore') 
group by player_name
having player_name = 'YS Chahal'or player_name ='DW Steyn'
order by Bowling_average desc
)
select w.player_name, wckts_taken, Bowling_average from wckts w left join bowling_average bow on w.player_name = bow.player_name
order by wckts_taken desc,Bowling_average asc;

-- -- -- -- -- All RCB Bowlers Bowling performance -- -- -- --
with wckts as (
select player_name, count(*) as wckts_taken
from ball_by_ball b join wicket_taken w on  b.match_id = w.match_id and b.over_id = w.over_id and b.ball_id = w.ball_id and b.innings_No = w.innings_no
left join matches m on b.match_id = m.match_id
join player p on b.bowler = p.player_id
where b.team_bowling = (select Team_Id from team where Team_Name='Royal Challengers Bangalore') 
group by player_name
order by wckts_taken desc
),
bowling_average as 
(
select player_name, sum(runs_scored)/count(distinct CONCAT(bb.Match_Id, '_', bb.Over_Id)) as Bowling_average from ball_by_ball bb
join batsman_scored ba 
on bb.match_id = ba.match_id and bb.over_id = ba.over_id and bb.ball_id = ba.ball_id and bb.innings_No = ba.innings_no 
join matches m on bb.match_id = m.match_id
join player p on bb.bowler = p.player_id
where bb.team_bowling = (select Team_Id from team where Team_Name='Royal Challengers Bangalore') 
group by player_name
order by Bowling_average desc
)
select w.player_name, wckts_taken, Bowling_average from wckts w left join bowling_average bow on w.player_name = bow.player_name
order by wckts_taken desc,Bowling_average asc;


-- 11: In the "Match" table, some entries in the "Opponent_Team" column are incorrectly spelled as "Delhi_Capitals" instead of "Delhi_Daredevils". Write an SQL query to replace all occurrences of "Delhi_Capitals" with "Delhi_Daredevils".

UPDATE Matches
SET Opponent_Team = 'Delhi_Daredevils'
WHERE Opponent_Team = 'Delhi_Capitals';


-- -- -- -- -- -- For Analysis -- -- -- -- -- --
with batting_position as (
select bl.striker,p.player_name, sum(ba.runs_scored)/count(distinct bl.match_id) as avg_runs_scored
from ball_by_ball bl join batsman_scored ba
on bl.Match_Id=ba.Match_Id
and bl.Over_Id=ba.Over_Id
and bl.Ball_Id=ba.Ball_Id
and bl.Innings_No=ba.Innings_No
and bl.Striker_Batting_Position in (5,6,7) 
join player p on bl.striker = p.player_id
group by bl.striker, p.player_name
)

select player_name, avg_runs_scored
from batting_position
order by avg_runs_scored desc;

-- -- -- -- Catches -- -- -- -- --
select player_name, count(*) as No_of_catches from wicket_taken w join player p on w.Fielders = p.player_id
where kind_out = 1
group by player_name
order by no_of_catches desc;

-- -- -- -- Bowlers having higher bowling average of RCB -- -- -- --
with over_death as (
select bowler, player_name ,sum(ba.runs_scored)/(count(bl.ball_id)/6) as bowling_average , count(bl.ball_id)/6 as overs_bowled
from ball_by_ball bl join batsman_scored ba
on bl.Match_Id=ba.Match_Id
and bl.Over_Id=ba.Over_Id
and bl.Ball_Id=ba.Ball_Id
and bl.Innings_No=ba.Innings_No
join player p on bl.Bowler = p.player_id
where bl.Team_Bowling=(select Team_Id from team where Team_Name='Royal Challengers Bangalore')
and bl.Over_Id in (16,17,18,19,20) 
group by bowler,player_name 
order by bowling_average desc
) 

select player_name, bowling_average as economy_in_death_overs, overs_bowled
from over_death;