#pragma once

typedef float wtime_t;

void create_timer();
void destroy_timer();
void start_timer();
void stop_timer();
wtime_t elapsed_millis();
