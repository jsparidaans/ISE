/*CREATE TABLE test_defaults (
  keycol 		smallint, 
  process_id 	smallint 	DEFAULT @@SPID, 
  date_ins 		datetime 	DEFAULT GETDATE(), 
  mathcol 		smallint 	DEFAULT 10 * 2, 
  text1 			char(3), 
  text2 			char(3) 		DEFAULT 'xyz'
) 

DEFAULT zet de default waarde wanneer deze niet wordt gegeven bij een INSERT */

INSERT test_defaults (text1) VALUES ('qqq') 

SELECT * FROM test_defaults


INSERT test_defaults (text1) VALUES ('qqq') 
insert test_defaults (text1,process_id) VALUES ('qqq', null)

insert test_defaults(text1,process_id)
VALUES  ('abc',null),
        ('def', 1),
        ('ghi', default)


SELECT * FROM test_defaults