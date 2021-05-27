import cli { Command, Flag }
import os
import time

fn pre_tests(tests_cmd Command) {
	print('The tests are started\n')
}

fn tests(tests_cmd Command) {
	tests_path := os.dir(os.args[0])
	v_compiler_path := os.args[1]
	input_files := os.walk_ext(tests_path, '_test.v')
	os.chdir(tests_path)
	for _, ipath in input_files {
		print('Test suite path is: $ipath\n')
		mut p := os.new_process(v_compiler_path)
		p.set_args(['test', ipath])
		p.run()
		mut i := 0
		for {
			if !p.is_alive() {
				break
			}
			// $if trace_process_output ? {
			// 	os.system('ps -opid= -oppid= -ouser= -onice= -of= -ovsz= -orss= -otime= -oargs= -p $p.pid')
			// }
			time.sleep(50 * time.millisecond)
			i++
		}
		p.wait()
		p.close()
	}
	print('\n')
}

fn post_tests(tests_cmd Command) {
	print('The tests are finished\n')
}

fn main() {
    mut cmd := Command{
        name: 'tests'
        description: 'Run V tests.'
        version: '0.1.0'
        usage: '<V lang binary full path>'
        required_args: 1
        pre_execute: pre_tests
        execute: tests
        post_execute: post_tests
    }
    cmd.add_command(cmd)
    cmd.parse(os.args)
}