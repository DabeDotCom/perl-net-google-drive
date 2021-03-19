#requires 'Net::Google::DataAPI';
requires 'perl', '5.008001';
requires 'Carp';
requires 'File::Basename';
requires 'HTTP::Request';
requires 'JSON';
requires 'LWP::UserAgent';
requires 'Net::Google::OAuth', '0.30.1';
requires 'Scalar::Util';
requires 'URI';

recommends 'Net::Google::Spreadsheets::V4';

on 'test' => sub {
    requires 'File::Spec';
    requires 'Test::More', '0.98';
};
