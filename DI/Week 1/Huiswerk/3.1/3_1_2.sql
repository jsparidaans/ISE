
alter table Person
add CONSTRAINT chk_pres_name check(
    (not (presentation != 1)) or NamePartner is not null
)