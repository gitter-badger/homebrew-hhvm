require 'formula'

class Hhvm < Formula
  homepage 'http://hhvm.com/'

  head do
    url 'https://github.com/facebook/hhvm.git'
    resource 'third-party' do
      url 'https://github.com/hhvm/hhvm-third-party.git'
    end
    #resource 'folly' do
    #  url 'https://github.com/facebook/folly.git'
    #end
  end

  stable do
    url 'https://github.com/facebook/hhvm/archive/HHVM-3.2.0.tar.gz'
    sha1 '039f97ae85244bdc5a06f0822f1f993f53badca5'
    resource 'third-party' do
      url 'https://github.com/hhvm/hhvm-third-party/archive/b9463da0d286a6f070803bdaa01df47309d508b7.tar.gz'
      sha1 '4105be9132230b7cfabc613ca9eff9c27ff259e7'
    end
    resource 'folly' do
      url 'https://github.com/facebook/folly/archive/09a81a96ea2f9790242675f3c84013266c38d684.tar.gz'
      sha1 'a62ff00b97813a05981ae687eea07d2ce509871d'
    end
  end

  option 'with-cotire', 'Speed up the build by precompiling headers.'
  option 'with-debug', 'Enable debug build (default Release).'
  option 'with-gcc48', 'Build with gcc-4.8 compiler.'
  option 'with-gcc49', 'Build with gcc-4.9 compiler.'
  option 'with-mariadb', 'Use mariadb as mysql package.'
  option 'with-minsizerel', 'Enable minimal size release build.'
  option 'with-percona-server', 'Use percona-server as mysql package.'
  option 'with-release-debug', 'Enable release with debug build.'
  option 'with-system-mysql', 'Try to use the mysql package installed on your system.'

  depends_on 'cmake' => :build
  depends_on 'libtool' => :build
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'pkg-config' => :build
  if build.with? 'gcc49'
    depends_on 'gcc49' => :build
  elsif build.with? 'gcc48'
    depends_on 'gcc48' => :build
  end

  # Standard packages
  depends_on 'boost'
  if build.with? 'gcc48' or build.with? 'gcc49'
    depends_on 'binutils'
  else
    depends_on 'binutilsfb'
  end
  depends_on 'curl'
  depends_on 'freetype'
  depends_on 'gd'
  depends_on 'gettext'
  depends_on 'glog'
  depends_on 'icu4c'
  depends_on 'imagemagick'
  depends_on 'imap-uw'
  depends_on 'jemallocfb'
  depends_on 'jpeg'
  depends_on 'libdwarf'
  depends_on 'libelf'
  depends_on 'libevent'
  depends_on 'libmemcached'
  depends_on 'libpng'
  depends_on 'libssh2'
  depends_on 'libxslt'
  depends_on 'mcrypt'
  depends_on 'objective-caml'
  depends_on 'oniguruma'
  depends_on 'pcre'
  depends_on 're2c'
  depends_on 'readline'
  depends_on 'sqlite'
  depends_on 'tbb'
  depends_on 'unixodbc'

  #MySQL packages
  if build.with? 'mariadb'
    depends_on 'mariadb'
  elsif build.with? 'percona-server'
    depends_on 'percona-server'
  elsif build.without? 'system-mysql'
    depends_on 'mysql'
    depends_on 'mysql-connector-c++'
  end

  patch :DATA unless build.head?

  def install
    if !build.with? 'gcc48' and !build.with? 'gcc49'
      raise "Currently only works with the --with-gcc48 or --with-gcc49"
    end
    args = [
      ".",
      "-DBOOST_INCLUDEDIR=#{Formula['boost'].opt_prefix}/include",
      "-DBOOST_LIBRARYDIR=#{Formula['boost'].opt_prefix}/lib",
      "-DCCLIENT_INCLUDE_PATH=#{Formula['imap-uw'].opt_prefix}/include/imap",
      "-DCMAKE_INCLUDE_PATH=\"#{HOMEBREW_PREFIX}/include:/usr/include\"",
      "-DCMAKE_INSTALL_PREFIX=#{prefix}",
      "-DCMAKE_LIBRARY_PATH=\"#{HOMEBREW_PREFIX}/lib:/usr/lib\"",
      "-DCURL_INCLUDE_DIR=#{Formula['curl'].opt_prefix}/include",
      "-DCURL_LIBRARY=#{Formula['curl'].opt_prefix}/lib/libcurl.dylib",
      "-DFREETYPE_INCLUDE_DIRS=#{Formula['freetype'].opt_prefix}/include/freetype2",
      "-DFREETYPE_LIBRARIES=#{Formula['freetype'].opt_prefix}/lib/libfreetype.dylib",
      "-DICU_DATA_LIBRARY=#{Formula['icu4c'].opt_prefix}/lib/libicudata.dylib",
      "-DICU_I18N_LIBRARY=#{Formula['icu4c'].opt_prefix}/lib/libicui18n.dylib",
      "-DICU_INCLUDE_DIR=#{Formula['icu4c'].opt_prefix}/include",
      "-DICU_LIBRARY=#{Formula['icu4c'].opt_prefix}/lib/libicuuc.dylib",
      "-DJEMALLOC_INCLUDE_DIR=#{Formula['jemallocfb'].opt_prefix}/include",
      "-DJEMALLOC_LIB=#{Formula['jemallocfb'].opt_prefix}/lib/libjemalloc.dylib",
      "-DLIBDWARF_INCLUDE_DIRS=#{Formula['libdwarf'].opt_prefix}/include",
      "-DLIBDWARF_LIBRARIES=#{Formula['libdwarf'].opt_prefix}/lib/libdwarf.3.dylib",
      "-DLIBELF_INCLUDE_DIRS=#{Formula['libelf'].opt_prefix}/include/libelf",
      "-DLIBEVENT_INCLUDE_DIR=#{Formula['libevent'].opt_prefix}/include",
      "-DLIBEVENT_LIB=#{Formula['libevent'].opt_prefix}/lib/libevent.dylib",
      "-DLIBGLOG_INCLUDE_DIR=#{Formula['glog'].opt_prefix}/include",
      "-DLIBINTL_INCLUDE_DIR=#{Formula['gettext'].opt_prefix}/include",
      "-DLIBINTL_LIBRARIES=#{Formula['gettext'].opt_prefix}/lib/libintl.dylib",
      "-DLIBJPEG_INCLUDE_DIRS=#{Formula['jpeg'].opt_prefix}/include",
      "-DLIBMAGICKWAND_INCLUDE_DIRS=#{Formula['imagemagick'].opt_prefix}/include/ImageMagick-6",
      "-DLIBMAGICKWAND_LIBRARIES=#{Formula['imagemagick'].opt_prefix}/lib/libMagickWand-6.Q16.dylib",
      "-DLIBMEMCACHED_INCLUDE_DIR=#{Formula['libmemcached'].opt_prefix}/include",
      "-DLIBODBC_INCLUDE_DIRS=#{Formula['unixodbc'].opt_prefix}/include",
      "-DLIBPNG_INCLUDE_DIRS=#{Formula['libpng'].opt_prefix}/include",
      "-DLIBSQLITE3_INCLUDE_DIR=#{Formula['sqlite'].opt_prefix}/include",
      "-DLIBSQLITE3_LIBRARY=#{Formula['sqlite'].opt_prefix}/lib/libsqlite3.0.dylib",
      "-DMcrypt_INCLUDE_DIR=#{Formula['mcrypt'].opt_prefix}/include",
      "-DOCAMLC_EXECUTABLE=#{Formula['objective-caml'].opt_prefix}/bin/ocamlc",
      "-DOCAMLC_OPT_EXECUTABLE=#{Formula['objective-caml'].opt_prefix}/bin/ocamlc.opt",
      "-DONIGURUMA_INCLUDE_DIR=#{Formula['oniguruma'].opt_prefix}/include",
      "-DPCRE_INCLUDE_DIR=#{Formula['pcre'].opt_prefix}/include",
      "-DREADLINE_INCLUDE_DIR=#{Formula['readline'].opt_prefix}/include",
      "-DREADLINE_LIBRARY=#{Formula['readline'].opt_prefix}/lib/libreadline.dylib",
      "-DTBB_INCLUDE_DIRS=#{Formula['tbb'].opt_prefix}/include",
      "-DTEST_TBB_INCLUDE_DIR=#{Formula['tbb'].opt_prefix}/include",
    ]

    if build.with? 'gcc49'
      args << "-DCMAKE_CXX_COMPILER=#{Formula['gcc49'].opt_prefix}/bin/g++-4.9"
      args << "-DCMAKE_C_COMPILER=#{Formula['gcc49'].opt_prefix}/bin/gcc-4.9"
      args << "-DCMAKE_ASM_COMPILER=#{Formula['gcc49'].opt_prefix}/bin/gcc-4.9"
      args << "-DBoost_USE_STATIC_LIBS=ON"
      args << "-DBFD_LIB=#{Formula['binutils'].opt_prefix}/lib/libbfd.a"
      args << "-DCMAKE_INCLUDE_PATH=#{Formula['binutils'].opt_prefix}/include"
      args << "-DLIBIBERTY_LIB=#{Formula['gcc49'].opt_prefix}/lib/x86_64/libiberty-4.9.a"
    elsif build.with? 'gcc48'
      args << "-DCMAKE_CXX_COMPILER=#{Formula['gcc49'].opt_prefix}/bin/g++-4.8"
      args << "-DCMAKE_C_COMPILER=#{Formula['gcc49'].opt_prefix}/bin/gcc-4.8"
      args << "-DCMAKE_ASM_COMPILER=#{Formula['gcc49'].opt_prefix}/bin/gcc-4.8"
      args << "-DBoost_USE_STATIC_LIBS=ON"
      args << "-DBFD_LIB=#{Formula['binutils'].opt_prefix}/lib/libbfd.a"
      args << "-DCMAKE_INCLUDE_PATH=#{Formula['binutils'].opt_prefix}/include"
      args << "-DLIBIBERTY_LIB=#{Formula['gcc48'].opt_prefix}/lib/x86_64/libiberty-4.8.a"
    else
      args << "-DBFD_LIB=#{Formula['binutilsfb'].opt_prefix}/lib/libbfd.a"
      args << "-DCMAKE_INCLUDE_PATH=#{Formula['binutilsfb'].opt_prefix}/include"
      args << "-DLIBIBERTY_LIB=#{Formula['binutilsfb'].opt_prefix}/lib/x86_64/libiberty.a"
    end

    if build.with? 'cotire'
      args << "-DENABLE_COTIRE=ON"
    end

    if build.with? 'debug'
      args << '-DCMAKE_BUILD_TYPE=Debug'
    elsif build.with? 'release-debug'
      args << '-DCMAKE_BUILD_TYPE=RelWithDebInfo'
    elsif build.with? 'minsizerel'
      args << '-DCMAKE_BUILD_TYPE=MinSizeRel'
    end

    if build.with? 'mariadb'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['mariadb'].opt_prefix}/include/mysql"
      args << "-DMYSQL_LIB_DIR=#{Formula['mariadb'].opt_prefix}/lib"
    elsif build.with? 'percona-server'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['percona-server'].opt_prefix}/include/mysql"
      args << "-DMYSQL_LIB_DIR=#{Formula['percona-server'].opt_prefix}/lib"
    elsif build.without? 'system-mysql'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['mysql'].opt_prefix}/include/mysql"
      args << "-DMYSQL_LIB_DIR=#{Formula['mysql'].opt_prefix}/lib"
    end

    #Custome packages
    rm_rf 'third-party'
    third_party_buildpath = buildpath/'third-party'
    third_party_buildpath.install resource('third-party')
    if build.stable?
      rm_rf 'third-party/folly/src'
      folly_buildpath = buildpath/'third-party/folly/src'
      folly_buildpath.install resource('folly')
    end

    src = prefix + "src"
    src.install Dir['*']

    ENV['HPHP_HOME'] = src

    cd src do
      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make install"
    end

    install_config
  end

  def install_config
    ini = etc + "hhvm/php.ini"
    ini.write default_php_ini unless File.exists? ini
  end

  def default_php_ini
    <<-EOS.undent
      ; php options
      date.timezone = Europe/London

      ; hhvm specific
      ; example: https://gist.github.com/denji/1a2ff183a671efcabedf
      hhvm.log.level = Warning
      hhvm.log.always_log_unhandled_exceptions = true
      hhvm.log.runtime_error_reporting_level = 8191
      hhvm.mysql.typed_results = false
      hhvm.eval.jit = false
    EOS
  end

  def caveats
    <<-EOS.undent
      If you have XQuartz (X11) installed,
      to temporarily remove a symbolic link at '/usr/X11R6'
      in order to successfully install HHVM.
        $ sudo rm /usr/X11R6
        $ sudo ln -s /opt/X11 /usr/X11R6

      If you are getting errors like 'Undefined symbols for architecture x86_64:',
      related to google or boost, execute:
        $ brew reinstall --build-from-source --cc=#{ENV.cc} boost gflags glog

      The php.ini file can be found in:
        #{etc}/hhvm/php.ini
    EOS
  end
end

__END__
diff --git a/hphp/runtime/ext/gd/libgd/gdft.cpp b/hphp/runtime/ext/gd/libgd/gdft.cpp
index 15b83c2..c6e3a38 100644
--- a/hphp/runtime/ext/gd/libgd/gdft.cpp
+++ b/hphp/runtime/ext/gd/libgd/gdft.cpp
@@ -62,7 +62,7 @@ gdImageStringFT (gdImage * im, int *brect, int fg, char *fontlist,
 
 #include "gdcache.h"
 
-#include <freetype/config/ftheader.h>
+#include <ft2build.h>
 
 #include FT_FREETYPE_H
 #include FT_GLYPH_H
diff --git a/hphp/runtime/base/emulate-zend.cpp b/hphp/runtime/base/emulate-zend.cpp
index c039301..a95188b 100644
--- a/hphp/runtime/base/emulate-zend.cpp
+++ b/hphp/runtime/base/emulate-zend.cpp
@@ -235,12 +235,12 @@ int emulate_zend(int argc, char** argv) {
 
     // If the -c option is specified without a -n, php behavior is to
     // load the default ini/hdf
-    auto default_config_file = "/etc/hhvm/php.ini";
+    auto default_config_file = "/usr/local/etc/hhvm/php.ini";
     if (access(default_config_file, R_OK) != -1) {
       newargv.push_back("-c");
       newargv.push_back(default_config_file);
     }
-    default_config_file = "/etc/hhvm/config.hdf";
+    default_config_file = "/usr/local/etc/hhvm/config.hdf";
     if (access(default_config_file, R_OK) != -1) {
       newargv.push_back("-c");
       newargv.push_back(default_config_file);
diff --git a/hphp/runtime/base/program-functions.cpp b/hphp/runtime/base/program-functions.cpp
index 4fe480c..f75040a 100644
--- a/hphp/runtime/base/program-functions.cpp
+++ b/hphp/runtime/base/program-functions.cpp
@@ -1150,12 +1150,12 @@ static int execute_program_impl(int argc, char** argv) {
       return -1;
     }
     if (po.config.empty() && !vm.count("no-config")) {
-      auto default_config_file = "/etc/hhvm/php.ini";
+      auto default_config_file = "/usr/local/etc/hhvm/php.ini";
       if (access(default_config_file, R_OK) != -1) {
         Logger::Verbose("Using default config file: %s", default_config_file);
         po.config.push_back(default_config_file);
       }
-      default_config_file = "/etc/hhvm/config.hdf";
+      default_config_file = "/usr/local/etc/hhvm/config.hdf";
       if (access(default_config_file, R_OK) != -1) {
         Logger::Verbose("Using default config file: %s", default_config_file);
         po.config.push_back(default_config_file);
