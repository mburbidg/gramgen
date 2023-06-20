package main

type Stack[T any] struct {
	top *slot[T]
}

type slot[T any] struct {
	data T
	prev *slot[T]
}

func NewStack[T any]() Stack[T] {
	return Stack[T]{}
}

func (s *Stack[T]) Top() (T, bool) {
	if s.top != nil {
		return s.top.data, true
	}
	return *new(T), false
}

func (s *Stack[T]) MustTop() T {
	return s.top.data
}

func (s *Stack[T]) Push(data T) *Stack[T] {
	slot := &slot[T]{data: data, prev: s.top}
	s.top = slot
	return s
}

func (s *Stack[T]) Pop() (T, bool) {
	if s.top != nil {
		data := s.top.data
		s.top = s.top.prev
		return data, true
	}
	return *new(T), false
}
