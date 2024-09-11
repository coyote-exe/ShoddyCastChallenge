/*
	Coyote: tyche-i implementation is NOT MINE. got it from https://github.com/bstatcomp/RandomCL/blob/master/generators/tyche_i.cl thank you guys for the amazing work!
	copy-pased as i failed to figure out how to #include using silk net and openCl
*/

/**
@file

Implements tyche-i RNG.

S. Neves, F. Araujo, Fast and small nonlinear pseudorandom number generators for computer simulation, in: International Conference on Parallel Processing and Applied Mathematics, Springer, 2011, pp. 92–101.
*/
#pragma once

#define TYCHE_I_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define TYCHE_I_DOUBLE_MULTI 5.4210108624275221700372640e-20

/**
State of tyche_i RNG.
*/
typedef union{
	struct{
		uint a,b,c,d;
	};
	ulong res;
} tyche_i_state;

#define TYCHE_I_ROT(a,b) (((a) >> (b)) | ((a) << (32 - (b))))
/**
Generates a random 64-bit unsigned integer using tyche_i RNG.

This is alternative, macro implementation of tyche_i RNG.

@param state State of the RNG to use.
*/
#define tyche_i_macro_ulong(state) (tyche_i_macro_advance(state), state.res)
#define tyche_i_macro_advance(state) ( \
	state.b = TYCHE_I_ROT(state.b, 7) ^ state.c, \
	state.c -= state.d, \
	state.d = TYCHE_I_ROT(state.d, 8) ^ state.a,\
	state.a -= state.b, \
	state.b = TYCHE_I_ROT(state.b, 12) ^ state.c, \
	state.c -= state.d, \
	state.d = TYCHE_I_ROT(state.d, 16) ^ state.a, \
	state.a -= state.b \
)

/**
Generates a random 64-bit unsigned integer using tyche_i RNG.

@param state State of the RNG to use.
*/
#define tyche_i_ulong(state) (tyche_i_advance(&state), state.res)
void tyche_i_advance(tyche_i_state* state){
	state->b = TYCHE_I_ROT(state->b, 7) ^ state->c;
	state->c -= state->d;
	state->d = TYCHE_I_ROT(state->d, 8) ^ state->a;
	state->a -= state->b;
	state->b = TYCHE_I_ROT(state->b, 12) ^ state->c;
	state->c -= state->d;
	state->d = TYCHE_I_ROT(state->d, 16) ^ state->a;
	state->a -= state->b;
}

/**
Seeds tyche_i RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void tyche_i_seed(tyche_i_state* state, ulong seed){
	state->a = seed >> 32;
	state->b = seed;
	state->c = 2654435769;
	state->d = 1367130551 ^ (get_global_id(0) + get_global_size(0) * (get_global_id(1) + get_global_size(1) * get_global_id(2)));
	for(uint i=0;i<20;i++){
		tyche_i_advance(state);
	}
}

/**
Generates a random 32-bit unsigned integer using tyche_i RNG.

@param state State of the RNG to use.
*/
#define tyche_i_uint(state) ((uint)tyche_i_ulong(state))

/**
Generates a random float using tyche_i RNG.

@param state State of the RNG to use.
*/
#define tyche_i_float(state) (tyche_i_ulong(state)*TYCHE_I_FLOAT_MULTI)

/**
Generates a random double using tyche_i RNG.

@param state State of the RNG to use.
*/
#define tyche_i_double(state) (tyche_i_ulong(state)*TYCHE_I_DOUBLE_MULTI)

/**
Generates a random double using tyche_i RNG. Since tyche_i returns 64-bit numbers this is equivalent to tyche_i_double.

@param state State of the RNG to use.
*/
#define tyche_i_double2(state) tyche_i_double(state)


 __kernel void hello_kernel(__global const long *a,__global int *result)
{
    long gid = get_global_id(0);
    tyche_i_state state;
	long seed = a[0] * gid;
	tyche_i_seed(&state,seed);
	int numbers[] = { 0, 0, 0, 0 };
	long rolls = 0;
	int maxOnes = 0;
	uint res = 0;
		for(int i = 0; i< 231; i++) // for i in repeat(None, 231):
        {
			res = tyche_i_uint(state);
            int roll = (int)(res%4); // roll = random.choice(items)
            numbers[roll] = numbers[roll] + 1; // numbers[roll - 1] = numbers[roll - 1] + 1
        }
		rolls = rolls + 1; // rolls = rolls + 1
		if (numbers[0] > maxOnes) // if numbers[0] > maxOnes:
            maxOnes = numbers[0]; // maxOnes = numbers[0]
    result[gid] = maxOnes;
}