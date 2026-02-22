# dart_cli_counter

CLI example using `opentui`.

## Run

```bash
cd /Users/jaichang/Documents/GitHub/flutter_opentui
dart run melos bootstrap
dart run examples/dart_cli_counter/bin/main.dart
```

Controls:

- `+`: increment counter.
- `-`: decrement counter.
- `Tab`: switch focus between input/select.
- `Ctrl+C`: exit.

## OpenCode-Style Demo

```bash
cd /Users/jaichang/Documents/GitHub/flutter_opentui
dart run examples/dart_cli_counter/bin/opencode.dart
```

Controls:

- `Tab`: move focus between tabs/files/editor/actions/slider/command bar.
- `Arrow`: navigate/select/edit in focused component.
- `Enter`:
  - on `Files`: open selected file into editor
  - on `Actions`: execute selected workflow
  - on `Command Bar`: execute slash command
- Slash commands: `/help`, `/run`, `/save`, `/open <index|name>`, `/reset`
- `Ctrl+C`: exit.
