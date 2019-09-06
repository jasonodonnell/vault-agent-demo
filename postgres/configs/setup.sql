CREATE ROLE vault;
ALTER ROLE vault WITH SUPERUSER LOGIN PASSWORD 'vault';

CREATE TABLE public.wizards(id int);
INSERT INTO public.wizards(id) VALUES (0);
