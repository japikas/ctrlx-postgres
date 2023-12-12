#!/bin/bash

TARGET_DIR=$SNAP_COMMON

chown snap_daemon:root $TARGET_DIR/*
chmod 750 $TARGET_DIR/*

chown snap_daemon:root $TARGET_DIR/data/*
chmod 750 $TARGET_DIR/data/*

chown snap_daemon:root $TARGET_DIR/log/*
chmod 750 $TARGET_DIR/log/*
