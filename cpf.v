import cli { Command, Flag }
import os
import encoding.csv

pub struct Filter {
    pub:
        target string
		expression string
	mut:
		items map[string]f32
}

// str returns the `string` representation of the `Filter`.
pub fn (filter Filter) str() string {
	mut res := []string{}
	res << 'Filter{'
	res << '	target: "$filter.target"'
	res << '}'
	return res.join('\n')
}

pub fn (mut filter Filter) parse() {
	filter.items = map[string]f32{}
	// It's a file
	if os.exists(filter.expression) {
		// Suppose it csv
		data := os.read_file(filter.expression) or { panic('error reading file ${filter.expression}') }
		mut parser := csv.new_reader(data + '\n')
		// read each line
		for {
			fields := parser.read() or { break }
			for field in fields {
				filter.items[field] = 1.0
			}
		}
	}
}

pub fn (filter Filter) copy_file(file string) {
	if file == '.' || file == '..' {
		return
	}
	file_name_with_extension := os.base(file)
	if filter.expression == '' {
		os.cp(file, os.join_path(filter.target, file_name_with_extension)) or { panic(err) }
		//print('Copy file 1: ${file} to ${os.join_path(filter.target, file_name_with_extension)}\n')
		return
	}
	if filter.items[file_name_with_extension] > 0 {
		os.cp(file, os.join_path(filter.target, file_name_with_extension)) or { panic(err) }
		//print('Copy file 2: ${file} to ${os.join_path(filter.target, file_name_with_extension)}\n')
		return
	}
	file_extension := os.file_ext(file)
	file_name_without_extension := file_name_with_extension.trim_suffix(file_extension)
	if filter.items[file_name_without_extension] > 0 {
		os.cp(file, os.join_path(filter.target, file_name_with_extension)) or { panic(err) }
		//print('Copy file 3: ${file} to ${os.join_path(filter.target, file_name_with_extension)}\n')
		return
	}
	return
}

pub fn (filter Filter) copy(path string) {
	if !os.is_dir(path) {
		return
	}
	mut files := os.ls(path) or { return }
	mut local_path_separator := os.path_separator
	if path.ends_with(os.path_separator) {
		local_path_separator = ''
	}
	for file in files {
		p := path + local_path_separator + file
		if os.is_dir(p) && !os.is_link(p) {
			filter.copy(p)
		} else if os.exists(p) {
			filter.copy_file(p)
		}
	}
	return
}


fn pre_copy(copy_command Command) ? {
	print('')
}

fn copy(copy_command Command) ? {
	//execution_path := os.dir(os.args[0])
    mut filter := Filter {
        target: copy_command.args[1]
		expression: copy_command.flags.get_string('filter') ?
    }
	filter.parse()
	filter.copy(copy_command.args[0])
}

fn post_copy(copy_command Command) ? {
	print('')
}

fn main() {
    mut command := Command{
        name: 'copy'
        description: 'Copy some files.'
        version: '0.1.0'
        usage: '<from-folder> <to-folder>'
        required_args: 2
        pre_execute: pre_copy
        execute: copy
        post_execute: post_copy
    }
    command.add_flag(Flag{
        flag: .string
        name: 'filter'
        abbrev: 'f'
        description: 'Define filter for copy.'
    })
    command.parse(os.args)
}
