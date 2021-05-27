import cli { Command, Flag }
import os

pub struct Filter {
    pub:
        target string
}

// str returns the `string` representation of the `Filter`.
pub fn (filter Filter) str() string {
	mut res := []string{}
	res << 'Filter{'
	res << '	target: "$filter.target"'
	res << '}'
	return res.join('\n')
}

pub fn (filter Filter) copy_file(file string) {
	if file == '.' || file == '..' {
		return
	}
	os.cp(file, os.join_path(filter.target, os.base(file))) or { panic(err) }
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


fn pre_cpf(cpf_cmd Command) {
	print('Pre')
}

fn cpf(cpf_cmd Command) {
	//execution_path := os.dir(os.args[0])
	from_path := os.args[1]
	to_path := os.args[2]
    filter := Filter {
        target: to_path
    }
	filter.copy(from_path)
}

fn post_cpf(cpf_cmd Command) {
	print('Post')
}

fn main() {
    mut cmd := Command{
        name: 'copy'
        description: 'Copy some files.'
        version: '0.1.0'
        usage: '<from-folder> <to-folder>'
        required_args: 2
        pre_execute: pre_cpf
        execute: cpf
        post_execute: post_cpf
    }
    cmd.add_flag(Flag{
        flag: .string
        name: 'filter'
        abbrev: 'f'
        description: 'Define filter for copy.'
    })
    cmd.add_command(cmd)
    cmd.parse(os.args)
}