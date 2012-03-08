void bubbleSort(int[] list) {
  swapped = false;
  for (int i = 1; i < n; ++i) {
    if (list[i] > list[i-1]) {
      swap(list, i-1, i);
      swapped = true;
    }
  }
  if (swapped) {
    --n;
    addSorted(list, n, n + 1);
    addComparing(list, 0, n);
  }
  else
    addSorted(list, 0, n);
} 

// Bottom-up merge sort
public void mergeSort(int[] list) {
  if (list.length < 2) {
    // We consider the list already sorted, no change is done
    return;
  }
  // startL - start index for left sub-list
  // startR - start index for the right sub-list

  if (step < list.length) {
    if (startR + step > list.length) {
      startL = 0;
      startR = step;
    }
    if (startR + step <= list.length) {
      mergeLists(list, startL, startL + step, startR, startR + step);
      startL = startR + step;
      startR = startL + step;
    }
    if (startR + step > list_2.length) {
      if (startR < list_2.length)
        mergeLists(list, startL, startL + step, startR, list_2.length);
      step *= 2;
    }
    addComparing(list, startL, startR);
  } 
  else
    addSorted(list, 0, listLength);
}

public void mergeLists(int[] list, int startL, int stopL, 
int startR, int stopR) {
  int[] right = new int[stopR - startR + 1];
  int[] left = new int[stopL - startL + 1];

  for (int i = 0, k = startR; i < (right.length - 1); ++i, ++k)
    right[i] = list[k];
  for (int i = 0, k = startL; i < (left.length - 1); ++i, ++k)
    left[i] = list[k];

  right[right.length-1] = Integer.MIN_VALUE;
  left[left.length-1] = Integer.MIN_VALUE;

  // Merging the two sorted list_2s into the initial one
  for (int k = startL, m = 0, n = 0; k < stopR; ++k) {
    if (left[m] > right[n]) {
      list[k] = left[m];
      m++;
    }
    else {
      list[k] = right[n];
      n++;
    }
  }
}

int Partition(int[] list, int lb, int ub ) {
  int a, down, temp, up, pj;
  a = list[lb];
  up = ub;
  down = lb;
  while (down < up) {
    while (list[down] >= a && down < up) {
      down=down+1;
    }
    while (list[up] < a) {
      up = up - 1;
    }
    if (down < up)
    {
      swap(list, down, up);
    }
  }
  list[lb] = list[up];
  list[up] = a;
  pj = up;
  addComparing(list, lb, ub + 1);
  addSorted(list, up, down + 1);
  return (pj);
}

void quickSort(int[] list) {
  if (!S.empty()) {
    int ub = (Integer)S.pop();
    int lb = (Integer)S.pop();
    if (ub <= lb) return;
    int i = Partition(list, lb, ub);
    if (i - lb > ub - i)
    {
      S.push(lb);
      S.push(i - 1);
    }
    S.push(i + 1);
    S.push(ub);
    if (ub-i >= i-lb)
    {
      S.push(lb);
      S.push(i-1);
    }
  }
}

public void heapSort(int[] list)
{
  // Establish the heap property.
  if (heapN == listLength - 1)
    for (int i = listLength/2; i >=0; i--)
      fixHeap(list, i, listLength - 1, list[i]);
  if (heapN >= 0) {
    // Now place the largest element last,
    // 2nd largest 2nd last, etc.
    // list[1] is the next-biggest element.
    swap(list, 0, heapN);

    // Heap shrinks by 1 element.
    fixHeap(list, 0, heapN - 1, list[0]);
    addSorted(list, heapN, heapN + 1);
    heapN--;
  }
}

/**
 Assuming that the partial order tree
 property holds for all descendants of
 the element at the root, make the
 property hold for the root also.
 
 @param root the index of the root
 of the current subtree
 @param end  the highest index of the heap
 */
void fixHeap(int[] list, int root, int end, 
int key)
{
  int child = 2*root; // left child
  int count = 0;
  // Find the larger child.
  if (child <= end && list[child] > list[child + 1]) {
    child++;  // right child is larger
    count += 2;
    addComparing(list, child, child+1);
    addComparing(list, end, end+1);
  }

  // If the larger child is larger than the
  // element at the root, move the larger child
  // to the root and filter the former root 
  // element down into the "larger" subtree.
  if (child <= end && key > list[child])
  {
    list[root] = list[child];
    fixHeap(list, child, end, key);
    addComparing(list, child, child+1);
    addComparing(list, key, key + 1);
  }
  else
    list[root] = key;
}

void swap(int[] list, int i, int j) {
  int temp = list[i];
  list[i] = list[j];
  list[j] = temp;
}

void addSorted(int[] list, int start, int end) {
  if (list.equals(list_1)) {
    for (int i = start; i < end; ++i)
      if (!sortedIndices1.contains(i))
        sortedIndices1.add(i);
  }
  else {
    for (int i = start; i < end; ++i)
      if (!sortedIndices2.contains(i))
        sortedIndices2.add(i);
  }
}

void clearComparing() {
  comparingIndices1.clear();
  comparingIndices2.clear();
}

void addComparing(int[] list, int start, int end) {
  if (list.equals(list_1)) {
    for (int i = start; i < end; ++i)
      if (!comparingIndices1.contains(i))
        comparingIndices1.add(i);
    sort1TotalCount += end - start;
  }
  else {
    for (int i = start; i < end; ++i)
      if (!comparingIndices2.contains(i))
        comparingIndices2.add(i);
    sort2TotalCount += end - start;
  }
}

