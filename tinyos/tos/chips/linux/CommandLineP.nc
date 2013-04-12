
module CommandLineP {
  provides {
    interface Init as SoftwareInit @exactlyonce();
    interface CommandLineArgs;
  }
}

implementation {

#define MAX_ARGS 20
#define MAX_ARG_LEN 100

  // 2D array of all of the arguments (white space separated)
  char args[MAX_ARGS][MAX_ARG_LEN];

  uint8_t num_args = 0;

  command error_t SoftwareInit.init() {
    int cmdline_fd;
    char fn_buf[100];
    pid_t process_id;
    int ret;
    uint8_t arg_buf[(MAX_ARGS*MAX_ARG_LEN) + 1];
    int i;


    // Get the filename to the cmdline file that contains the arguments
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

    // Add a null character at the end of the file contents just in case.
    // This ensures that the last argument will be null terminated when it is
    // saved in the array.
    arg_buf[ret] = '\0';

    {
      // Copy all arguments into our nice 2d array
      // All whitespace has been converted to '\0' by linux
      bool arg_started = FALSE;
      int arg_idx = -1;
      int arg_char_idx = 0;

      for (i=0; i<=ret; i++) {
        if (arg_buf[i] == 0) {
          // Skip whitespace
          if (arg_started && arg_char_idx < MAX_ARG_LEN) {
            // add the null byte
            args[arg_idx][arg_char_idx++] = '\0';
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

        if (arg_char_idx >= (MAX_ARG_LEN-1)) {
          // Skip the remainder of the argument after MAX_ARG_LEN
          // Save 1 byte for the null terminator
          continue;
        }
        if (arg_idx >= MAX_ARGS) {
          break;
        }

        args[arg_idx][arg_char_idx++] = arg_buf[i];

      }

      num_args = arg_idx + 1;
    }

    CMDLINE_PRINTF("Number of args: %i\n", num_args);
    for (i=0; i<num_args; i++) {
      CMDLINE_PRINTF("arg%02i: %s\n", i, args[i]);
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
