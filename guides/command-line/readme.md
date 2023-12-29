# Command Line

This guide show you how to use the CLI. The CLI is useful for creating new projects and running the server.

## Creating a new project

To create a new project, you need to use the `new` command:

```bash
lenna new my_app
```

This command will create a new project in the `my_app` directory. Initially, the project will have the following structure:

```bash
my_app
├── Gemfile
├── Gemfile.lock
├── app
│   └── application.rb
└── config.ru
```

## Running the server

To run the server, you need to use the `server` command:

```bash
lenna server
```

This command will start the server on port 3000. You can change the port using the `-p` option:

```bash
lenna server -p 8080
```

The default server is `puma`. You can change the server using the `-s` option:

```bash
lenna server -s thin
```

But, you need to add the server to the `Gemfile` and change the `config.ru`.

Done! Now you can start to develop your application.
