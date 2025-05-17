arr = [0]*256


f = open('tmp.txt', 'r')
lines = f.readlines()
for i in lines:
	tmp = i.split('\t')
	index = int(tmp[0], 16)
	print(tmp[1].split(' ')[-1])
	value = int(tmp[1].split(' ')[-1])
	arr[index] = value
print(arr)