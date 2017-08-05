This middle library purpose is easy use NI daqmx dll library in matlab.
So , only do basic data type translate. And maybe it is demo how to
call dll in matlab also.
Thanks Nathan Tomlin (nathan.a.tomlin {at} gmail.com) write "daqmx
example" first.

===== How to make yourself mat2dll librarys ( dll write by C functions ) =====

1. use calllib() in matlab.
2. Any value position directly input to target function by calllib() function.
3. Any pointer position use libpointer() make a pointer object then input to
	target function by calllib() function. It's include pointer and array.

About pointer object: (This is my guess.)
Pointer object allow you read a fix memory area , but can't change it.
So only external program can change this memory area.
If you don't use pointer object, matlab will record value and map to other
memory. So after call dll , your variable will not change .

example:
1,2.
% c function : int out = func_in_dll(int arg1, double arg2);
out = calllib(lib,'func_in_dll', arg1, arg2)

3.
% c function : int out = func_in_dll(int arg1, double *arg2, double arg[] );
arg2_ptr = libpointer('doublePtr',arg2);
arg3_ptr = libpointer('doublePtr',arg3);
out = calllib(lib,'func_in_dll', arg1, arg2_ptr, arg3_ptr);
fprintf('arg2 = %g',arg2_ptr.Value);
fprintf('arg3 = %g',arg3_ptr.Value);

