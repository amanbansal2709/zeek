##! Interface for the ASCII log writer.  Redefinable options are available
##! to tweak the output format of ASCII logs.
##!
##! The ASCII writer currently supports one writer-specific per-filter config
##! option: setting ``tsv`` to the string ``T`` turns the output into
##! "tab-separated-value" mode where only a single header row with the column
##! names is printed out as meta information, with no "# fields" prepended; no
##! other meta data gets included in that mode.  Example filter using this::
##!
##!    local f: Log::Filter = [$name = "my-filter",
##!                            $writer = Log::WRITER_ASCII,
##!                            $config = table(["tsv"] = "T")];
##!

module LogAscii;

export {
	## If true, output everything to stdout rather than
	## into files. This is primarily for debugging purposes.
	##
	## This option is also available as a per-filter ``$config`` option.
	const output_to_stdout = F &redef;

	## If true, the default will be to write logs in a JSON format.
	##
	## This option is also available as a per-filter ``$config`` option.
	const use_json = F &redef;

	## Format of timestamps when writing out JSON. By default, the JSON
	## formatter will use double values for timestamps which represent the
	## number of seconds from the UNIX epoch.
	##
	## This option is also available as a per-filter ``$config`` option.
	const json_timestamps: JSON::TimestampFormat = JSON::TS_EPOCH &redef;

	## If true, include lines with log meta information such as column names
	## with types, the values of ASCII logging options that are in use, and
	## the time when the file was opened and closed (the latter at the end).
	##
	## If writing in JSON format, this is implicitly disabled.
	const include_meta = T &redef;

	## Prefix for lines with meta information.
	##
	## This option is also available as a per-filter ``$config`` option.
	const meta_prefix = "#" &redef;

	## Separator between fields.
	##
	## This option is also available as a per-filter ``$config`` option.
	const separator = Log::separator &redef;

	## Separator between set elements.
	##
	## This option is also available as a per-filter ``$config`` option.
	const set_separator = Log::set_separator &redef;

	## String to use for empty fields. This should be different from
	## *unset_field* to make the output unambiguous.
	##
	## This option is also available as a per-filter ``$config`` option.
	const empty_field = Log::empty_field &redef;

	## String to use for an unset &optional field.
	##
	## This option is also available as a per-filter ``$config`` option.
	const unset_field = Log::unset_field &redef;

	## A hint for a maximum size that a log entry's final textual representation
	## should not substantially exceed. It's not hard limit, but the writer will start
	## truncating the output if it's reached. The writer will however still produce
	## syntactically correct output.
	const size_limit_hint: count = 1 * 1024 * 1024 &redef;
}

# Default function to postprocess a rotated ASCII log file. It moves the rotated
# file to a new name that includes a timestamp with the opening time, and then
# runs the writer's default postprocessor command on it.
function default_rotation_postprocessor_func(info: Log::RotationInfo) : bool
	{
	# Move file to name including both opening and closing time.
	local dst = fmt("%s.%s.log", info$path,
			strftime(Log::default_rotation_date_format, info$open));

	system(fmt("/bin/mv %s %s", info$fname, dst));

	# Run default postprocessor.
	return Log::run_rotation_postprocessor_cmd(info, dst);
	}

redef Log::default_rotation_postprocessors += { [Log::WRITER_ASCII] = default_rotation_postprocessor_func };
