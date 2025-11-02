#!/bin/bash
# Скрипт локальной сборки ядра Realme C35 с KernelSU + SUSFS
# Требования: Ubuntu 20.04+ с 8GB RAM и 50GB диска

set -e

echo "🚀 Начинаю сборку ядра Realme C35..."

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Проверка зависимостей
echo -e "${YELLOW}📦 Проверка зависимостей...${NC}"
if ! command -v clang &> /dev/null; then
    echo -e "${RED}❌ clang не найден! Установите зависимости:${NC}"
    echo "sudo apt-get install -y build-essential bc gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi libssl-dev libfl-dev bison flex"
    exit 1
fi

# Конфигурация
KERNEL_DIR=$(pwd)
TOOLCHAIN_DIR="${KERNEL_DIR}/../toolchains"
OUT_DIR="${KERNEL_DIR}/out"
BUILD_DATE=$(date +%Y%m%d)

# Какой вариант собирать? (можно изменить)
DEFCONFIG="realme_c35_nyx_ksu_susfs_defconfig"  # KSU + SUSFS
# DEFCONFIG="realme_c35_nyx_ksu_defconfig"      # Только KSU
# DEFCONFIG="realme_c35_nyx_defconfig"          # Без KSU

KERNEL_NAME=$(echo $DEFCONFIG | sed 's/_defconfig//')

echo -e "${GREEN}🔧 Конфигурация: ${KERNEL_NAME}${NC}"

# Создать директорию для вывода
mkdir -p ${OUT_DIR}

# Скачать тулчейны если их нет
if [ ! -d "${TOOLCHAIN_DIR}/clang" ]; then
    echo -e "${YELLOW}📥 Скачиваю тулчейны...${NC}"
    mkdir -p ${TOOLCHAIN_DIR}
    cd ${TOOLCHAIN_DIR}

    echo "Cloning Clang..."
    git clone --depth=1 -b lineage-20.0 \
        https://github.com/rifsxd/android_prebuilts_clang_kernel_linux-x86_clang-r416183b clang

    echo "Cloning GCC aarch64..."
    git clone --depth=1 -b lineage-19.1 \
        https://github.com/rifsxd/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 aarch64

    echo "Cloning GCC arm..."
    git clone --depth=1 -b lineage-19.1 \
        https://github.com/rifsxd/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 arm

    cd ${KERNEL_DIR}
fi

# Экспорт переменных окружения
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=${TOOLCHAIN_DIR}/aarch64/bin/aarch64-linux-android-
export CROSS_COMPILE_ARM32=${TOOLCHAIN_DIR}/arm/bin/arm-linux-androideabi-
export CC=${TOOLCHAIN_DIR}/clang/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export LD=${TOOLCHAIN_DIR}/clang/bin/ld.lld
export AR=${TOOLCHAIN_DIR}/clang/bin/llvm-ar
export NM=${TOOLCHAIN_DIR}/clang/bin/llvm-nm
export OBJCOPY=${TOOLCHAIN_DIR}/clang/bin/llvm-objcopy
export OBJDUMP=${TOOLCHAIN_DIR}/clang/bin/llvm-objdump
export READELF=${TOOLCHAIN_DIR}/clang/bin/llvm-readelf
export STRIP=${TOOLCHAIN_DIR}/clang/bin/llvm-strip
export KBUILD_BUILD_HOST=local-build
export KBUILD_BUILD_USER=$(whoami)

# Настроить KernelSU (если нужно)
if [[ "$DEFCONFIG" == *"ksu"* ]]; then
    echo -e "${YELLOW}🔐 Настраиваю KernelSU...${NC}"

    # Удалить старый KernelSU
    rm -rf ./KernelSU
    rm -rf ./drivers/kernelsu

    # Скачать и применить KernelSU
    curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -s next
fi

# Очистить предыдущую сборку
echo -e "${YELLOW}🧹 Очистка...${NC}"
make O=${OUT_DIR} clean
make O=${OUT_DIR} mrproper

# Применить конфигурацию
echo -e "${YELLOW}⚙️  Применяю конфигурацию ${DEFCONFIG}...${NC}"
make O=${OUT_DIR} ARCH=${ARCH} ${DEFCONFIG}

# Автоматически применить значения по умолчанию для новых опций
# Это предотвращает интерактивные вопросы во время сборки
echo -e "${YELLOW}⚙️  Применяю значения по умолчанию для новых опций...${NC}"
make O=${OUT_DIR} ARCH=${ARCH} olddefconfig

# Собрать ядро
echo -e "${GREEN}🔨 Собираю ядро (это займет 15-30 минут)...${NC}"
make O=${OUT_DIR} -j$(nproc) \
    ARCH=${ARCH} \
    CC="${CC}" \
    CLANG_TRIPLE=${CLANG_TRIPLE} \
    CROSS_COMPILE=${CROSS_COMPILE} \
    CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
    LD=${LD} \
    AR=${AR} \
    NM=${NM} \
    OBJCOPY=${OBJCOPY} \
    OBJDUMP=${OBJDUMP} \
    READELF=${READELF} \
    STRIP=${STRIP}

# Проверить результат
if [ -f "${OUT_DIR}/arch/arm64/boot/Image" ]; then
    echo -e "${GREEN}✅ Сборка успешна!${NC}"
    echo ""
    echo "📦 Результаты сборки:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ls -lh ${OUT_DIR}/arch/arm64/boot/Image*
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${GREEN}📁 Файлы находятся в: ${OUT_DIR}/arch/arm64/boot/${NC}"
    echo ""
    echo "Для прошивки используйте:"
    echo "  • Image.gz-dtb (если есть)"
    echo "  • или Image.gz + dtbo"
else
    echo -e "${RED}❌ Ошибка сборки!${NC}"
    exit 1
fi
