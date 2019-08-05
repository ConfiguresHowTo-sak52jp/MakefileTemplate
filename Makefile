#-- DUTのCソース --
DUT_C_SRCS := <BaseNameOfSrcs>
#-- DUTのC++ソース --
DUT_CXX_SRCS := <BaseNameOfSrcs>
#-- DUTのソースディレクトリ --
DUT_SRCDIR := $(abspath <PathToDir>)

#-- Test DriverのC++ソース --
TEST_CXX_SRCS := <BaseNameOfSrcs>
#-- Test Driverのソースディレクトリ --
TEST_SRCDIR := $(abspath <PathToDir>)

#-- Coverage測定前提のフラグ設定(DUT) --
COMMON_FLAGS := -O0 -g3 -Wall -MMD -fprofile-arcs -ftest-coverage
CFLAGS := $(COMMON_FLAGS) -std=c99
CXXFLAGS := $(COMMON_FLAGS) -std=c++11

#-- Test DriverはCoverage対象外 --
COMMON_FLAGS_T := -O0 -g3 -Wall -MMD
CFLAGS_T := $(COMMON_FLAGS_T) -std=c99
CXXFLAGS_T := $(COMMON_FLAGS_T) -std=c++11

#-- C++ソースがあったら実行形式ビルダはg++ --
BUILDER := gcc
BUILD_FLAGS := $(CFLAGS)
ifneq ($(strip $(DUT_CXX_SRCS) $(TEST_CXX_SRCS)),)
	BUILDER := g++
	BUILD_FLAGS := $(CXXFLAGS)
endif

#-- 実行形式 --
TARGET := <NameOfExecutable>

#--------------------- Rules ---------------------------
OBJS := $(notdir $(DUT_C_SRCS) $(DUT_CXX_SRCS) $(TEST_CXX_SRCS))
OBJS := $(OBJS:.c=.o)
OBJS := $(OBJS:.cpp=.o)

all:$(TARGET)

exec_test:$(TARGET)
	./$(TARGET)
	mkdir -p coverage
	lcov -q --capture --directory . --output-file lcov.info
	lcov -q --remove lcov.info "*/usr/*" --output-file lcov2.info
	genhtml --branch-coverage --output-directory coverage lcov2.info

$(TARGET):$(OBJS)
	$(BUILDER) $(BUILD_FLAGS) -o $@ $^ -lgcov -lgtest -lpthread -lm

-include $(OBJS:.o=.d)

clean:
	rm -rf $(OBJS) $(TARGET) *~

realclean: clean
	rm -rf $(OBJS:.o=.d) $(OBJS:.o=.gcda) $(OBJS:.o=.gcno) *.info coverage

.PHONY: all exec_test clean realclean

%.o:$(DUT_SRCDIR)/%.c
	gcc -c -o $@ $(CFLAGS) $<

%.o:$(TEST_SRCDIR)/%.c
	gcc -c -o $@ $(CFLAGS_T) $<

%.o:$(DUT_SRCDIR)/%.cpp
	g++ -c -o $@ $(CXXFLAGS) $<

%.o:$(TEST_SRCDIR)/%.cpp
	g++ -c -o $@ $(CXXFLAGS_T) $<



