
module CommandLineP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface CommandLineArgs;
  }
}

implementation {

#define MAX_ARGS 20
#define MAX_ARG_LEN 100

  char args[MAX_ARGS][MAX_ARG_LEN];

  uint8_t num_args = 0;

  command error_t SoftwareInit.init() {
    int cmdline_fd;
    char fn_buf[100];
    pid_t process_id;
    int ret;
    uint8_t arg_buf[MAX_ARGS*MAX_ARG_LEN];
    int i;

    process_id = getpid();

    ret = snprintf(fn_buf, 100, "/proc/%i/cmdline", process_id);

    cmdline_fd = open(fn_buf, O_RDONLY);
    if (cmdline_fd == -1) {
      ERROR("Unabled to open file of command line arguments.\n");
      return FAIL;
    }

    ret = read(cmdline_fd, arg_buf, MAX_ARGS*MAX_ARG_LEN);
    if (ret == -1) {
      ERROR("Unable to read from command line file.\n");
      return FAIL;
    }

    printf("arg string: %s\n", arg_buf);

    {
      // Copy all arguments into our nice 2d array
      bool arg_started = FALSE;
      int arg_idx = -1;
      int arg_char_idx = 0;

      for (i=0; i<ret; i++) {
        if (arg_buf[i] == 0) {
          // Skip whitespace
          if (arg_started && arg_char_idx < MAX_ARG_LEN) {
            // add the null byte
            args[arg_idx][arg_char_idx++] = '\0';
            printf("arg%i: %s\n", arg_idx, args[arg_idx]);
          }
          arg_started = FALSE;
          continue;
        }

        if (!arg_started) {
          // start a new argument
          arg_idx++;
          arg_started = TRUE;
          arg_char_idx = 0;
        }

        if (arg_char_idx >= MAX_ARG_LEN) {
          continue;
        }
        if (arg_idx >= MAX_ARGS) {
          break;
        }

        args[arg_idx][arg_char_idx++] = arg_buf[i];

      }

      num_args = arg_idx + 1;
    }

    return SUCCESS;
  }

  command uint8_t CommandLineArgs.count () {
    return num_args;
  }

  command char* CommandLineArgs.getArg (uint8_t arg_idx) {
    if (arg_idx >= num_args) {
      return NULL;
    }
    return args[arg_idx];
  }

}
