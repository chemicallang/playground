FROM chemicallang/chemical:v0.0.25

COPY . .

# currently only debug_quick is supported, this would
RUN chemical build.lab -o build.exe --mode debug_quick --no-cache

# We need the llvm version for llvm ir generation
RUN wget -q https://github.com/chemicallang/chemical/releases/download/v0.0.25/linux-x64.zip \
    && unzip linux-x64.zip \
    && rm linux-x64.zip

ENV PATH="/opt/linux:${PATH}"

RUN chmod -R +x linux

RUN chemical --configure

# Export necessary port
EXPOSE 8080

# Command to run when starting the container
CMD ["./build/playground.dir/playground"]