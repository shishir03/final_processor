#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct dict_t_struct {
    char *key;
    void *value;
    struct dict_t_struct *next;
} dict_t;

dict_t** dictAlloc() {
    return malloc(sizeof(dict_t));
}

void dictDealloc(dict_t **dict) {
    free(dict);
}

void* getItem(dict_t *dict, char *key) {
    dict_t *ptr;
    for (ptr = dict; ptr != NULL; ptr = ptr->next) {
        if (strcmp(ptr->key, key) == 0) {
            return ptr->value;
        }
    }

    return NULL;
}

void delItem(dict_t **dict, char *key) {
    dict_t *ptr, *prev;
    for (ptr = *dict, prev = NULL; ptr != NULL; prev = ptr, ptr = ptr->next) {
        if (strcmp(ptr->key, key) == 0) {
            if (ptr->next != NULL) {
                if (prev == NULL) {
                    *dict = ptr->next;
                } else {
                    prev->next = ptr->next;
                }
            } else if (prev != NULL) {
                prev->next = NULL;
            } else {
                *dict = NULL;
            }

            free(ptr->key);
            free(ptr);

            return;
        }
    }
}

void addItem(dict_t **dict, char *key, void *value) {
    delItem(dict, key);
    dict_t *d = malloc(sizeof(struct dict_t_struct));
    d->key = malloc(strlen(key)+1);
    strcpy(d->key, key);
    d->value = value;
    d->next = *dict;
    *dict = d;
}

dict_t** init_opcodes() {
    dict_t** opcodes = dictAlloc();
    addItem(opcodes, "add", "00000");
    addItem(opcodes, "sub", "00001");
    addItem(opcodes, "lbr", "00010");
    addItem(opcodes, "sbr", "00011");
    addItem(opcodes, "lb", "001");
    addItem(opcodes, "subi", "010");
    addItem(opcodes, "addi", "011");
    addItem(opcodes, "beq", "10000");
    addItem(opcodes, "bne", "10001");
    addItem(opcodes, "blt", "10010");
    addItem(opcodes, "ble", "10011");
    addItem(opcodes, "mov", "101");
    addItem(opcodes, "lsl", "11000");
    addItem(opcodes, "asr", "11001");
    addItem(opcodes, "lsr", "11010");
    addItem(opcodes, "not", "11011");
    addItem(opcodes, "and", "11101");
    addItem(opcodes, "xor", "11110");
    addItem(opcodes, "rxor", "11111");
    return opcodes;
}

int reg_value(char* reg) {
    return atoi(reg + 1);
}

char* intToBinaryString(int n) {
    int numBits = 4;

    char* binaryString = (char*)malloc(numBits + 1);
    if (binaryString == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        exit(1);
    }

    int i;
    for (i = numBits - 1; i >= 0; i--) {
        int bit = (n >> i) & 1;
        binaryString[numBits - 1 - i] = bit + '0';
    }
    binaryString[numBits] = '\0';

    return binaryString;
}

char* reg_to_addr(char* reg) {
    return intToBinaryString(reg_value(reg));
}

void convert(char* in, char* out) {
    FILE* f_in = fopen(in, "r");
    FILE* f_out = fopen(out, "w");
    dict_t** opcodes = init_opcodes();
    char line[256];

    while(fgets(line, sizeof(line), f_in) != NULL) {
        char* token = strtok(line, " ");
        fprintf(f_out, "%s", (char*) getItem(*opcodes, token));
        if(!strcmp(token, "add") || !strcmp(token, "sub") || !strcmp(token, "lbr") || !strcmp(token, "sbr")
            || !strcmp(token, "lsr") || !strcmp(token, "asr") || !strcmp(token, "lsl") || !strcmp(token, "not")
            || !strcmp(token, "and") || !strcmp(token, "xor") || !strcmp(token, "rxor")) {       // R type instructions
            char* dest = strtok(NULL, " ");
            char* d_addr = reg_to_addr(dest);
            fprintf(f_out, "%s", d_addr);
            free(d_addr);
        } else if(!strcmp(token, "lb") || !strcmp(token, "subi") || !strcmp(token, "addi")) {  // I type instructions
            char* rt = strtok(NULL, " ");
            char* immed = strtok(NULL, " ");
            immed[5] = '\0';
            char* rt_addr = (!reg_value(rt)) ? "0" : "1";
            fprintf(f_out, "%s%s", immed, rt_addr);
        } else if(!strcmp(token, "beq") || !strcmp(token, "bne") || !strcmp(token, "blt") || !strcmp(token, "ble")) {  // B type instructions
            char* immed = strtok(NULL, " ");
            immed[4] = '\0';
            fprintf(f_out, "%s", immed);
        } else if(!strcmp(token, "mov")) {
            char* rt = strtok(NULL, " ");
            char* rs = strtok(NULL, " ");

            if(reg_value(rt) == 0 || reg_value(rt) == 1) {
                fprintf(f_out, "0");
                if(!reg_value(rt)) fprintf(f_out, "0");
                else fprintf(f_out, "1");
                char* rs_addr = reg_to_addr(rs);
                fprintf(f_out, "%s", rs_addr);
                free(rs_addr);
            } else {
                fprintf(f_out, "1");
                char* rt_addr = reg_to_addr(rt);
                fprintf(f_out, "%s", rt_addr);
                free(rt_addr);
                if(reg_value(rs) == 0) fprintf(f_out, "0");
                else fprintf(f_out, "1");
            }
        }

        fprintf(f_out, "\n");
    }

    dictDealloc(opcodes);
}

int main(int argc, char** argv) {
    if(argc == 3) {
        convert(argv[1], argv[2]);
        return EXIT_SUCCESS;
    } else return EXIT_FAILURE;
}
