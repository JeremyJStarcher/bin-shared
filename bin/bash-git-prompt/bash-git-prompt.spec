%global START_TOKEN ### Generated by %{name} rpm package
%global END_TOKEN ### Generated by %{name} rpm package

Name:		bash-git-prompt
Version:	2.6.1
Release:	1%{?dist}
Summary:	Informative git prompt for bash and fish

Group:		Development/Tools
License:	FreeBSD
URL:		https://github.com/magicmonty/bash-git-prompt.git
Source0:        https://github.com/magicmonty/%{name}/archive/%{version}.tar.gz
Requires:       git
BuildArch:      noarch

%description
A bash prompt that displays information about the current git repository. In particular the branch name, difference with remote branch, number of files staged, changed, etc.

This package will automatically enable the git prompt for bash after
install. It will disable the prompt accordingly after uninstall.

%prep
%setup -q


%build


%install
rm -rf %{buildroot}

install -d 755 %{buildroot}%{_datadir}/%{name}
install -pm 755 *.sh %{buildroot}%{_datadir}/%{name}
#install -pm 755 *.py %{buildroot}%{_datadir}/%{name}
install -pm 755 *.fish %{buildroot}%{_datadir}/%{name}
install -pm 644 README.md %{buildroot}%{_datadir}/%{name}
install -d 755 %{buildroot}%{_datadir}/%{name}/themes
install -pm 644 themes/*.bgptheme %{buildroot}%{_datadir}/%{name}/themes
install -pm 644 themes/*.bgptemplate %{buildroot}%{_datadir}/%{name}/themes

# never include compiled Python program
#rm -fr  %{buildroot}%{_datadir}/%{name}/*.pyo
#rm -fr  %{buildroot}%{_datadir}/%{name}/*.pyc


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_datadir}/%{name}


%post
# enable bash-git-prompt
cat << EOF >> /etc/bashrc
%{START_TOKEN}
if [ -f %{_datadir}/%{name}/gitprompt.sh ]; then
    # Set config variables first

    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_THEME=Default
    source %{_datadir}/%{name}/gitprompt.sh
fi
%{END_TOKEN}
EOF

%postun
# remove bash-git-prompt setup
sed -i -e '/^%{START_TOKEN}/, /^%{END_TOKEN}/{d}' /etc/bashrc

%doc README.md

%license License.txt

%changelog
* Fri Aug 08 2014 Justin Zhang <schnell18@gmail.com - 1.0.1-1
- Initial version of package
