/*
 * Copyright 2021 The CFU-Playground Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef CFU_PLAYGROUND_PERF_H_
#define CFU_PLAYGROUND_PERF_H_

#ifdef __cplusplus
extern "C" {
#endif

#define NUM_PERF_COUNTERS 8

extern unsigned CFU_start_counts[NUM_PERF_COUNTERS];

inline void perf_zero_start_counts() {
  for (int i = 0; i < NUM_PERF_COUNTERS; ++i) {
    CFU_start_counts[i] = 0;
  }
}

inline unsigned perf_get_start_count(int counter_num) {
  return CFU_start_counts[counter_num];
}

inline unsigned perf_get_mcycle() {
  unsigned result;
  asm volatile("csrr %0, mcycle" : "=r"(result));
  return result;
}

inline void perf_set_mcycle(unsigned cyc) {
  asm volatile("csrw mcycle, %0" ::"r"(cyc));
}

inline unsigned perf_get_counter(int counter_num) {
  unsigned count = 0;
#ifndef NPROFILE
  switch (counter_num) {
    case 0:
      asm volatile("csrr %0, 0xB04" : "=r"(count));
      break;
    case 1:
      asm volatile("csrr %0, 0xB06" : "=r"(count));
      break;
    case 2:
      asm volatile("csrr %0, 0xB08" : "=r"(count));
      break;
    case 3:
      asm volatile("csrr %0, 0xB0A" : "=r"(count));
      break;
    case 4:
      asm volatile("csrr %0, 0xB0C" : "=r"(count));
      break;
    case 5:
      asm volatile("csrr %0, 0xB0E" : "=r"(count));
      break;
    case 6:
      asm volatile("csrr %0, 0xB10" : "=r"(count));
      break;
    case 7:
      asm volatile("csrr %0, 0xB12" : "=r"(count));
      break;
    default:;
  }
#endif
  return count;
}

inline unsigned perf_get_counter_enable(int counter_num) {
  unsigned en = 0;
#ifndef NPROFILE
  switch (counter_num) {
    case 0:
      asm volatile("csrr %0, 0xB05" : "=r"(en));
      break;
    case 1:
      asm volatile("csrr %0, 0xB07" : "=r"(en));
      break;
    case 2:
      asm volatile("csrr %0, 0xB09" : "=r"(en));
      break;
    case 3:
      asm volatile("csrr %0, 0xB0B" : "=r"(en));
      break;
    case 4:
      asm volatile("csrr %0, 0xB0D" : "=r"(en));
      break;
    case 5:
      asm volatile("csrr %0, 0xB0F" : "=r"(en));
      break;
    case 6:
      asm volatile("csrr %0, 0xB11" : "=r"(en));
      break;
    case 7:
      asm volatile("csrr %0, 0xB13" : "=r"(en));
      break;
    default:;
  }
#endif
  return en;
}

inline void perf_set_counter(int counter_num, unsigned count) {
#ifndef NPROFILE
  switch (counter_num) {
    case 0:
      asm volatile("csrw 0xB04, %0" ::"r"(count));
      break;
    case 1:
      asm volatile("csrw 0xB06, %0" ::"r"(count));
      break;
    case 2:
      asm volatile("csrw 0xB08, %0" ::"r"(count));
      break;
    case 3:
      asm volatile("csrw 0xB0A, %0" ::"r"(count));
      break;
    case 4:
      asm volatile("csrw 0xB0C, %0" ::"r"(count));
      break;
    case 5:
      asm volatile("csrw 0xB0E, %0" ::"r"(count));
      break;
    case 6:
      asm volatile("csrw 0xB10, %0" ::"r"(count));
      break;
    case 7:
      asm volatile("csrw 0xB12, %0" ::"r"(count));
      break;
    default:;
  }
#endif
}

inline void perf_set_counter_enable(int counter_num, unsigned en) {
  if (en) {
    CFU_start_counts[counter_num]++;
  }
#ifndef NPROFILE
  switch (counter_num) {
    case 0:
      asm volatile("csrw 0xB05, %0" ::"r"(en));
      break;
    case 1:
      asm volatile("csrw 0xB07, %0" ::"r"(en));
      break;
    case 2:
      asm volatile("csrw 0xB09, %0" ::"r"(en));
      break;
    case 3:
      asm volatile("csrw 0xB0B, %0" ::"r"(en));
      break;
    case 4:
      asm volatile("csrw 0xB0D, %0" ::"r"(en));
      break;
    case 5:
      asm volatile("csrw 0xB0F, %0" ::"r"(en));
      break;
    case 6:
      asm volatile("csrw 0xB11, %0" ::"r"(en));
      break;
    case 7:
      asm volatile("csrw 0xB13, %0" ::"r"(en));
      break;
    default:;
  }
#endif
}

inline void perf_enable_counter(int counter_num) {
  perf_set_counter_enable(counter_num, 1);
}

inline void perf_disable_counter(int counter_num) {
  perf_set_counter_enable(counter_num, 0);
}

// Print a human readable number (useful for perf counters)
void perf_print_human(unsigned n);

// Print a value in both human readable and precise forms (also useful for perf
// counters)
void perf_print_value(unsigned n);

// Set each individual perf counter to zero
void perf_reset_all_counters();

// Prints cycle and enable counts for every perf coutner
void perf_print_all_counters();

// Test menu
void perf_test_menu(void);

#ifdef __cplusplus
}
#endif
#endif  // CFU_PLAYGROUND_PERF_H_
