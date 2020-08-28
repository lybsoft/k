cd ~
sudo apt install axel git build-essential python2
wget http://mirrors.kernel.org/ubuntu/pool/main/m/mpfr4/libmpfr4_3.1.4-1_amd64.deb
dpkg -i libmpfr4_3.1.4-1_amd64.deb
rm libmpfr4_3.1.4-1_amd64.deb

# gcc 8.3

mkdir 83
axel "https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-eabi.tar.xz?revision=402e6a13-cb73-48dc-8218-ad75d6be0e01&la=en&hash=D665067126F18E366570F5B4FCCB3882DF2E7BF8"
axel "https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-aarch64-elf.tar.xz?revision=d678fd94-0ac4-485a-8054-1fbc60622a89&la=en&hash=983B477DA9B33107F58777D880FBAD2D3103C130"
cd 83
tar xf gcc-arm-8.3-2019.03-x86_64-arm-eabi.tar.xz
tar xf gcc-arm-8.3-2019.03-x86_64-aarch64-elf.tar.xz
cd ..

# gcc 9.2

axel "https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz?revision=ea238776-c7c7-43be-ba0d-40d7f594af1f&la=en&hash=2937ED76D3E6B85BA511BCBD46AE121DBA5268F3"
axel "https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-arm-none-eabi.tar.xz?revision=64186c5d-b471-4c97-a8f5-b1b300d6594a&la=en&hash=5E9204DA5AF0B055B5B0F50C53E185FAA10FF625"
cd 92
tar xf gcc-arm-9.2-2019.12-x86_64-arm-none-eabi.tar.xz
tar xf gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz
cd ..

# get ubertc
git clone https://bitbucket.org/UBERTC/aarch64-linux-android-4.9-kernel.git --depth=1
git clone https://bitbucket.org/UBERTC/arm-eabi-4.9.git --depth=1
