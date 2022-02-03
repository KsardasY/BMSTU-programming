int *mas;

int scanmas(int mas[], int n)
{
	for(int i = 0; i < n; i++)
		scanf("%d", &mas[i]);
	return *mas;
}

int compare(unsigned long i, unsigned long j)
{
	if (mas[i] < mas[j]) return -1;
	else if (mas[i] == mas[j]) return 0;
	else return 1;
}

void swap(unsigned long i, unsigned long j)
{
	int tmp = mas[i];
	mas[i] = mas[j];
	mas[j] = tmp;
}

void printmas(int mas[], int n)
{
	for(int i = 0; i < n; i++)
	{
		printf("%d ", mas[i]);
		if (i == n-1) printf("\n");
	}
}


int main()
{
	int n;
	scanf("%d", &n);

	mas = (int*) malloc(n * sizeof(int));
	*mas = scanmas(mas,n);

	ANYsort(n, compare, swap);

	printmas(mas, n);

	free(mas);
	return 0;
}