
#!/bin/bash
ORIG_CWD=`pwd`
TMPDIR=${ORIG_CWD}/mytest

# Load the extract3 function
source ./bash_aliases.sh

cleanup() {
    if test -d $TMPDIR; then
        rm -rf $TMPDIR
    fi

    cd $ORIG_CWD
}

init_test() {
    mkdir -p $TMPDIR
    cd $TMPDIR

    # Create a sample text file to compress
    echo "This is a test file." > sample.txt
}


# Test cases
test_valid_file() {
  local input="$1"
  local expected_output="$2"
  extract3 "$input"
  local result=$?

  if [[ $result -eq 0 ]]; then
    echo "Test passed for valid file: $input"
  else
    echo "Test failed for valid file: $input"
  fi
}

test_invalid_file() {
  local input="$1"
  local expected_error="$2"
  local error_output
  error_output=$(extract3 "$input" 2>&1)
  local result=$?

  if [[ $result -ne 0 && $error_output == *"$expected_error"* ]]; then
    echo "Test passed for invalid file: $input"
  else
    echo "Test failed for invalid file: $input"
  fi
}



nah() {

cleanup

# Create a test_files directory
mkdir -p test_files


# Change to the test_files directory
cd test_files


# tar.gz
tar -czf sample_tar_gz.tar.gz sample.txt

# bz2
bzip2 -zk sample_bz2.txt

# rar (Requires rar or unrar to be installed)
rar a sample_rar.rar sample.txt

# gz
gzip -kc sample_gz.txt > sample.gz

# tar
tar -cf sample_tar.tar sample.txt

# zip
zip sample_zip.zip sample.txt

# z (Requires compress utility to be installed)
compress -c sample_z.txt > sample.z

# 7z (Requires p7zip or p7zip-full to be installed)
7z a sample_7z.7z sample.txt

# Return to the parent directory
cd ..

echo "Compressed test files generated in the test_files directory."



# Test with valid files
for file in test_files/*; do
  test_valid_file "$file"
done

# Test with invalid files
test_invalid_file "non_existent_file.tar.gz" "is not a valid file"
test_invalid_file "" "is not a valid file"
test_invalid_file "test_directory" "is not a valid file"
test_invalid_file "unsupported.txt" "cannot be extracted via extract()"

cd ..    
rm -rf $TMPDIR
.

}

function test_bz2() {
    init_test
    file=sample_bz2.tar.bz2
    # Compress the sample text file into various formats
    # tar.bz2
    tar -cjf "$file" sample.txt

    test_valid_file "$file"

}

echo "Starting dir ${ORIG_CWD}"
echo "Temp Dir ${TMPDIR}"

cleanup
test_bz2
