import cli { Command, Flag }
import os

fn pre_cpf(cpf_cmd Command) {
	print('Pre')
}

fn cpf(cpf_cmd Command) {
	print('Ok')
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