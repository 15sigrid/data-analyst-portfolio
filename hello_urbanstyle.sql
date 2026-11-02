-- Minu esimene UrbanStyle päring
-- Nimi: Sigrid Nielander
-- Kuupäev: 2026-11-02

-- Loo meeskonnaliikmete tabel
create table if not exists team_members (
    id serial primary key,
    name varchar(100) not null,
    role varchar(100),
    week int default 0,
    joined_at timestamp default now()
);

-- Lisa minu andmed
insert into team_members (name, role, week)
values ('Sigrid Nielander', 'Andmeanalüütik', 0);

-- Vaata tulemust
select *
from team_members
order by joined_at;
