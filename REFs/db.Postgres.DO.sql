--  pl/pgSQL : DO is anonymous code block (like a function)
-- https://stackoverflow.com/questions/62568057/how-to-use-variables-in-postgresql-transaction

BEGIN; -- Transaction
    DO
    $$
        DECLARE
            v int; -- capture result(s) of select from t1
        begin
        select c1 INTO v from t1 where k1=1;
            if not found then
                raise exception 'no row found';
            else -- insert the captured results into t2
                insert INTO t2(c2) VALUES(v);
            end if;
        end;
    $$;
COMMIT;

