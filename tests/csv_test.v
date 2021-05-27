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

	os.mkdir(folder1) or { panic(err) }
	os.mkdir(folder2) or { panic(err) }

	create_file(os.join_path(folder1, 'file1.txt'))
	create_file(os.join_path(folder1, 'file2.txt'))
	create_file(os.join_path(folder1, 'file3.txt'))

	$if windows {
		os.execute('cpf.exe')
	} $else {
		os.execute('cpf')
	}

	print('OK current folder is: ${os.getwd()}')
}


// fn test_create_file() {
// 	filename := './test1.txt'
// 	hello := 'hello world!'
// 	mut f := os.create(filename) or { panic(err) }
// 	f.write_string(hello) or { panic(err) }
// 	f.close()
// 	assert hello.len == os.file_size(filename)
// 	os.rm(filename) or { panic(err) }
// }

// fn test_is_file() {
// 	// Setup
// 	work_dir := os.join_path(os.getwd(), 'is_file_test')
// 	os.mkdir_all(work_dir) or { panic(err) }
// 	tfile := os.join_path(work_dir, 'tmp_file')
// 	// Test things that shouldn't be a file
// 	assert os.is_file(work_dir) == false
// 	assert os.is_file('non-existent_file.tmp') == false
// 	// Test file
// 	tfile_content := 'temporary file'
// 	os.write_file(tfile, tfile_content) or { panic(err) }
// 	assert os.is_file(tfile)
// 	// Test dir symlinks
// 	$if windows {
// 		assert true
// 	} $else {
// 		dsymlink := os.join_path(work_dir, 'dir_symlink')
// 		os.system('ln -s $work_dir $dsymlink')
// 		assert os.is_file(dsymlink) == false
// 	}
// 	// Test file symlinks
// 	$if windows {
// 		assert true
// 	} $else {
// 		fsymlink := os.join_path(work_dir, 'file_symlink')
// 		os.system('ln -s $tfile $fsymlink')
// 		assert os.is_file(fsymlink)
// 	}
// }

// fn test_write_and_read_string_to_file() {
// 	filename := './test1.txt'
// 	hello := 'hello world!'
// 	os.write_file(filename, hello) or { panic(err) }
// 	assert hello.len == os.file_size(filename)
// 	read_hello := os.read_file(filename) or { panic('error reading file $filename') }
// 	assert hello == read_hello
// 	os.rm(filename) or { panic(err) }
// }