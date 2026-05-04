# N-Back Math

A small mobile-first web demo for arithmetic-flavored `n-back`.
This repo is a static frontend only. There is no backend service in the project.

## Rules

- A new arithmetic problem appears every round.
- While viewing the current problem, answer the one from `N` steps back.
- `N` can be set from `1` to `12`.
- Prompts always use single-digit `0-9` addition and subtraction.
- Subtraction never goes negative.

## Local use

Open `index.html` directly or serve the folder with any static file server.

## Controls

- Tap digits to enter an answer.
- Tap `CLR` to clear the current answer.
- Correct answers auto-advance immediately.
- Keyboard digits and `Backspace` work too.

## Settings

- `N Level`: `1-back` through `12-back`
- `Scored Rounds`: `10`, `15`, `20`, or `30`
- `Speed`: `Slow` (`3s`) or `Fast` (`1s`)
