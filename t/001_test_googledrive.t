#
#===============================================================================
#
#         FILE: 002_test_googledrive.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 28.09.2018 23:14:47
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use lib 'lib';
use File::Basename;
use File::Spec;
use Data::Printer;
use Net::Google::Drive;

use Test::More 'no_plan';

BEGIN {
    use_ok("Net::Google::Drive");
}

my $CLIENT_ID       = $ENV{GOOGLE_CLIENT_ID}        // '593952972427-e6dr18ua0leurrjtu9gl1766t1je1num.apps.googleusercontent.com';
my $CLIENT_SECRET   = $ENV{GOOGLE_CLIENT_SECRET}    // 'pK99-WlEd7kr7YcWIAVFOQpu';
my $ACCESS_TOKEN    = $ENV{GOOGLE_ACCESS_TOKEN}     // 'ya29.GlspBipu9sdZKYmO4t90eDiEUVIQ2mhIVuPWothJa2Xwihow_ka889DFPWt3GSSrSpvh3mWjKUCDn-QlRxZRxBuCuaRDFZ5Q9w2w5SHFYOn6f_F2JASA34xgbakr';
my $REFRESH_TOKEN   = $ENV{GOOGLE_REFRESH_TOKEN}    // '1/uKe_YszQbrwA6tHI5Att-VOYuktWt5iV9Q5fy-DrEjE';

my $TEST_DOWNLOAD_FILE = 't/test_download';
my $TEST_UPLOAD_FILE = 't/gogle_upload_file';


unlink ($TEST_DOWNLOAD_FILE);

my $drive = Net::Google::Drive->new(
                                        -client_id      => $CLIENT_ID,
                                        -client_secret  => $CLIENT_SECRET,
                                        -access_token   => $ACCESS_TOKEN,
                                        -refresh_token  => $REFRESH_TOKEN,
                                    );
isa_ok($drive, 'Net::Google::Drive');


####### TESTS ######
my $test_download_file_id = testSearchFileByName($drive);
testSearchFileByNameContains($drive);

#### Download file
testDownloadFile($drive, $test_download_file_id);

#### Upload file
my $upload_file_id = testUploadFile($drive);
#### Get metadata
testGetFileMetadata($drive, $upload_file_id);
#### Set permission
testSetFilePermissionWrong($drive, $upload_file_id);
testSetFilePermission($drive, $upload_file_id, 'anyone');
#### Share file


#### Delete file
testDeleteFile($drive, $upload_file_id);


sub testSearchFileByName{
    my ($drive) = @_;
    my $files = $drive->searchFileByName(
                            -filename   => 'drive_file.t',
                        );
    is (scalar(@$files), 1, "Test searchFileByName");
    return $files->[0]->{id};
}

sub testSearchFileByNameContains {
    my ($drive) = @_;
    my $files = $drive->searchFileByNameContains(
                                -filename   => 'Тестовый',
                            );
    is (scalar(@$files), 1, "Test searchFileByNameContains");
}

sub testDownloadFile {
    my ($drive, $file_id) = @_;
    
    my $res = $drive->downloadFile(
                                    -file_id        => $file_id,
                                    -dest_file      => $TEST_DOWNLOAD_FILE,
                                );
    ok($res, 'Test downloadFile() ok');
    ok(-e $TEST_DOWNLOAD_FILE, 'Download file exists');
}

sub testDeleteFile {
    my ($drive, $file_id) = @_;

    my $res = $drive->deleteFile(
                                    -file_id        => $file_id,
                                );
    ok($res, 'Test deleteFile() ok');
}

sub testUploadFile {
    my ($drive) = @_;

    my $res = $drive->uploadFile(
                                    -source_file    => $TEST_UPLOAD_FILE,
                                );
    ok($res, 'Test upload file');
    my $file_id = $res->{id};
    ok($file_id, "Uploaded file id: $file_id");
    return $file_id;
}

sub testGetFileMetadata {
    my ($drive, $file_id) = @_;

    my $metadata = $drive->getFileMetadata(
                                            -file_id        => $file_id,
                                        );
    ok($metadata, 'Get file metadata');
}

sub testSetFilePermissionWrong {
    my ($drive, $file_id) = @_;
    eval {
        $drive->setFilePermission(
                                                    -file_id        => $file_id,
                                                    -permission     => 'test'
                                                );
    };
    like ($@, qr/^Wrong permission/, 'Test wrong permission');
}

sub testFileSetPermission {
    my ($drive, $file_id, $permission) = @_;
    my $perm = $drive->setFilePermission(
                                                -file_id        => $file_id,
                                                -permission     => $permission,
                                                -role           => 'reader',          
                                            );
    is($perm->{permission}, $permission, 'Test setFilePermission()');
}
