import os

fn create_file(filename string) {
	hello := 'hello world!'
	mut f := os.create(filename) or { panic(err) }
	f.write_string(hello) or { panic(err) }
	f.close()
}

fn test_copy_all() {
	folder1 := os.join_path(os.getwd(), 'build', 'folder1')
	if os.exists(folder1) {
		os.rmdir_all(folder1) or { panic(err) }
	}
	folder2 := os.join_path(os.getwd(), 'build', 'folder2')
	if os.exists(folder2) {
		os.rmdir_all(folder2) or { panic(err) }
	}

	os.mkdir_all(folder1) or { panic(err) }
	os.mkdir_all(folder2) or { panic(err) }

	create_file(os.join_path(folder1, 'file1.txt'))
	create_file(os.join_path(folder1, 'file2.txt'))
	create_file(os.join_path(folder1, 'file3.txt'))

	$if windows {
		os.execute('cpf.exe $folder1 $folder2')
	} $else {
		os.execute('cpf $folder1 $folder2')
	}

	assert os.walk_ext(folder2, '.txt').len == 3

	print('OK current folder is: ${os.getwd()}')
}

