create role chirpstack_as;
create database chirpstack with owner chirpstack;
\c chirpstack_as
create extension pg_trgm;
create extension hstore;
\q

