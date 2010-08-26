use Module::Build;
my $build = Module::Build->new(
        license     => 'perl',
        dist_author => 'Dave Cross <dave@mag-sol.com>',
	module_name => 'Net::Songkick',
	license => 'perl',
	requires => {
		perl           => '5.6.0',
		LWP::UserAgent => 0,
		Moose	       => 0,
	},
	build_recommends => {
		Test::Pod           => 0,
		Test::Pod::Coverage => 0,
	},
        create_makefile_pl => 'traditional',
);

$build->create_build_script;

