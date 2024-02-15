package main

import (
	"fmt"
	"math/rand"
	"sync"
	"sync/atomic"
	"time"
)

const num_of_philosophers = 5

var mealFlag = true
var mealing_time = 20

type Fork struct {
	locked atomic.Bool
}

func (f *Fork) takeFork() {
	for f.locked.Load() {
	}
	f.locked.Swap(true)
}

func (f *Fork) free() {
	f.locked.Swap(false)
}

type Table struct {
	ready bool
	forks [num_of_philosophers]Fork
}

type Philosopher struct {
	lfork            *Fork
	rfork            *Fork
	num              int
	table            *Table
	phthread         *sync.WaitGroup
	status           string
	numFinishedMeals int
}

func newPhilosopher(_num int, _table *Table, l *Fork, r *Fork) *Philosopher {
	p := &Philosopher{
		num:   _num,
		table: _table,
		lfork: l,
		rfork: r,
	}
	p.phthread = &sync.WaitGroup{}
	p.phthread.Add(1)
	go p.process()
	return p
}

func (p *Philosopher) eat() {
	p.lfork.takeFork()
	p.status = "taking left fork"
	time.Sleep(time.Duration(rand.Intn(3)+1) * 100 * time.Millisecond)

	p.rfork.takeFork()
	p.status = "is eating"
	time.Sleep(time.Duration(rand.Intn(3)+1) * 100 * time.Millisecond)

	p.status = "finished eating"
	p.lfork.free()
	p.rfork.free()
	p.numFinishedMeals++
}

func (p *Philosopher) think() {
	time.Sleep(time.Duration(rand.Intn(3)+1) * 100 * time.Millisecond)
	p.status = "is thinking"
}

func (p *Philosopher) get_status() string {
	return fmt.Sprintf("%d: %s ", p.num, p.status)
}

func (p *Philosopher) process() {
	for !p.table.ready {
	}
	for p.table.ready && mealFlag {
		p.think()
		if !mealFlag {
			break
		}
		p.eat()
	}
	p.phthread.Done()
}

func main() {
	fmt.Println("Start getting meal for ", num_of_philosophers, " guests")

	table := Table{}
	philosophers := []*Philosopher{
		newPhilosopher(1, &table, &table.forks[0], &table.forks[1]),
		newPhilosopher(2, &table, &table.forks[1], &table.forks[2]),
		newPhilosopher(3, &table, &table.forks[2], &table.forks[3]),
		newPhilosopher(4, &table, &table.forks[3], &table.forks[4]),
		newPhilosopher(5, &table, &table.forks[0], &table.forks[4]),
	}

	table.ready = true

	for t := 0; t < mealing_time; t++ {
		for _, philosopher := range philosophers {
			fmt.Print(philosopher.get_status())
		}
		fmt.Println()
		time.Sleep(250 * time.Millisecond)
	}

	mealFlag = false
	fmt.Println("End mealing.")
	for _, philosopher := range philosophers {
		fmt.Println(philosopher.numFinishedMeals)
		philosopher.phthread.Wait()
	}
}
