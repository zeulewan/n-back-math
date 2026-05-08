# N-Back Math

A small mobile-first web demo for arithmetic-flavored `n-back`.
This repo is a static frontend only. There is no backend service in the project.

## Rules

- A new arithmetic problem appears every round.
- While viewing the current problem, answer the one from `N` steps back.
- `N` can be set from `1` to `12`.
- Every run has `24` scored questions.
- Prompts always use single-digit `0-9` addition and subtraction.
- Subtraction never goes negative.

## Local use

Open `index.html` directly or serve the folder with any static file server.

## Controls

- Tap digits to enter an answer.
- Tap `CLR` to clear the current answer.
- Correct answers auto-advance immediately.
- Keyboard digits and `Backspace` work too.

## Level

Use the `-` and `+` buttons to step through the level sequence:
`Slow 1-back`, `Fast 1-back`, `Slow 2-back`, `Fast 2-back`, and so on
through `Fast 12-back`.

- `Slow`: `4s`
- `Fast`: `3s`
