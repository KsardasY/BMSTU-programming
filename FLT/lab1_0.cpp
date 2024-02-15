#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <cassert>

using namespace std;


struct Node {
    string tag;
    Node *parent;
    vector<Node *> children;

    Node(const string &tag, Node *parent = nullptr) {
        this->tag = tag;
        this->parent = parent;
        if (parent != nullptr) {
            parent->children.push_back(this);
        }
    }
};


Node* create_tree(string &str) {
    int level = 0, first_index = 0;
    map<int, Node*> current_parent;
    Node* res = nullptr;
    Node* last_node;
    for (int i = 0; i < str.length(); i++) {
        if (str[i] == '(' || (str[i - 1] != ')' && (str[i] == ')' || str[i] == ','))) {
            if (level == 0) {
                res = new Node(str.substr(first_index, i - first_index));
                last_node = res;
            } else {
                last_node = new Node(str.substr(first_index, i - first_index), current_parent[level - 1]);
            }
        }
        if (str[i] == '(') {
            current_parent[level] = last_node;
            level++;
            first_index = i + 1;
        } else if (str[i] == ')') {
            level--;
        } else if (str[i] == ',') {
            first_index = i + 2;
        }
    }
    if (res == nullptr) {
        res = new Node(str);
    }
    return res;
}


string tree_to_str(Node* node, string& str) {
    str += node->tag;
    if (node->children.empty()) {
        return str;
    }
    str += '(';
    str = tree_to_str(node->children[0], str);
    for (int i = 1; i < node->children.size(); i++) {
        str += ", ";
        str = tree_to_str(node->children[i], str);
    }
    str += ')';
    return str;
}


bool equal_tree(Node* node1, Node* node2) {
    if (node1->tag != node2->tag or node1->children.size() != node2->children.size()) {
        return false;
    }
    for (int i = 0; i < node1->children.size(); i++) {
        if (!equal_tree(node1->children[i], node2->children[i])) {
            return false;
        }
    }
    return true;
}


Node* copy_tree(Node* node, Node* parent = nullptr) {
    Node* new_node = nullptr;
    if (parent != nullptr) {
        new_node = new Node(node->tag, parent);
    } else {
        new_node = new Node(node->tag);
    }
    parent = new_node;
    for (int i = 0; i < node->children.size(); i++) {
        copy_tree(node->children[i], parent);
    }
    return new_node;
}


bool equivalent_tree(Node* node1, Node* node2, map<string, Node*> &var) {
    if (node1->children.empty()) {
        if (var.count(node1->tag)) {
            if (!equal_tree(var[node1->tag], node2)) {
                return false;
            }
        } else {
            var[node1->tag] = copy_tree(node2);
        }
    } else {
        if (node1->tag != node2->tag or node1->children.size() != node2->children.size()) {
            return false;
        }
        for (int i = 0; i < node1->children.size(); i++) {
            if (!equivalent_tree(node1->children[i], node2->children[i], var)) {
                return false;
            }
        }
    }
    return true;
}


void delete_tree(Node* node) {
    for (int i = 0; i < node->children.size(); i++) {
        delete_tree(node->children[i]);
    }
    delete node;
}


void insert_tree(Node* subtree, Node* place) {
    if (place->parent != nullptr) {
        auto it = find(
                place->parent->children.begin(),
                place->parent->children.end(),
                place);
        int index = it - place->parent->children.begin();
        place->parent->children[index] = subtree;
    }
    subtree->parent = place->parent;
    *place = *subtree;
}


void get_nodes(Node* node, vector<Node*> &res) {
    res.push_back(node);
    for (int i = 0; i < node->children.size(); i++) {
        get_nodes(node->children[i], res);
    }
}


bool in_tree(Node* tree, string &tag) {
    bool res = false;
    vector<Node*> nodes;
    get_nodes(tree, nodes);
    for (int i = 0; i < nodes.size(); i++) {
        if (nodes[i]->tag == tag) {
            res = true;
        }
    }
    return res;
}


void rewrite(Node* node, map<string, Node*> &var) {
    vector<Node*> nodes;
    get_nodes(node, nodes);
    for (int i = 0; i < nodes.size(); i++) {
        if (nodes[i]->children.empty() and var.count(nodes[i]->tag)) {
            string str;
            insert_tree(copy_tree(var[nodes[i]->tag]), nodes[i]);
        }
    }
}


void add_word(Node* word, vector<Node*> &res_words) {
    bool f = false;
    for (int i = 0; i < res_words.size(); i++) {
        f = f || equal_tree(word, res_words[i]);
    }
    if (!f) {
        res_words.push_back(word);
    }
}


void rule_word(Node* left, Node* right, Node* word, vector<Node*> &res_words) {
    vector<Node*> nodes;
    get_nodes(word, nodes);
    for (int i = 0; i < nodes.size(); i++) {
        if (left->children.empty() || nodes[i]->tag == left->tag) {
            map<string, Node*> var;
            bool res = equivalent_tree(left, nodes[i], var);
            if (res) {
                Node* subtree = copy_tree(right);
                rewrite(subtree, var);
                Node* res_word = copy_tree(word);
                vector<Node*> new_nodes;
                get_nodes(res_word, new_nodes);
                insert_tree(subtree, new_nodes[i]);
                add_word(res_word, res_words);
            }
            for (auto p : var) {
                delete_tree(p.second);
            }
        }
    }
}


vector<Node*> rule_iteration(vector<pair<Node*, Node*>> rules, Node* word) {
    vector<Node*> res_words;
    for (int i = 0; i < rules.size(); i++) {
        rule_word(rules[i].first, rules[i].second, word, res_words);
    }
    return res_words;
}


void rewriting_step(vector<pair<Node*, Node*>> rules, vector<Node*> words, vector<Node*> &res, vector<Node*> &cnst) {
    for (int i = 0; i < words.size(); i++) {
        vector<Node*> res_words = rule_iteration(rules, words[i]);
        if (!res_words.empty()) {
            for (int j = 0; j < res_words.size(); j++) {
                add_word(res_words[j], res);
            }
        } else {
            add_word(copy_tree(words[i]), cnst);
        }
    }
}
vector<Node*> rewriting_cycle(vector<pair<Node*, Node*>> rules, Node* word, int n_steps) {
    vector<Node*> words, cnst, res;
    words.push_back(word);
    for (int i = 0; i < n_steps; i++) {
        vector<Node*> res;
        rewriting_step(rules, words, res, cnst);
        words = res;
//        for (int j = 0; j < res.size(); j++) {
//            delete_tree(res[i]);
//        }
    }
    for (int i = 0; i < cnst.size(); i++) {
        add_word(cnst[i], words);
    }
    return words;
}


vector<pair<Node*, Node*>> get_rules(string path) {
    vector<pair<Node*, Node*>> rules;
    string str;
    ifstream file(path);
    assert(file.is_open());
    while (getline(file, str)) {
        int index = str.find(" -> ");
        string left = str.substr(0, index);
        string right = str.substr(index + 4, str.length() - (index + 4));
        Node* l = create_tree(left);
        Node* r = create_tree(right);
        rules.push_back(make_pair(l, r));
    }
    return rules;
}


string get_word(string path) {
    string str;
    ifstream file(path);
    assert(file.is_open());
    getline(file, str);
    return str;
}


int main(int argc, char** argv) {
    string rules_path, word_path, str, s;
    int n_steps;
    cout << "Введите путь к файлу с грамматикой: " << endl;
    getline(cin, rules_path);
    cout << "Введите путь к файлу со словом: " << endl;
    getline(cin, word_path);
    cout << "Введите количество шагов переписывания: " << endl;
    cin >> n_steps;
    vector<pair<Node*, Node*>> rules = get_rules(rules_path);
    string w = get_word(word_path);
    Node* word = create_tree(w);
    vector<Node*> res = rewriting_cycle(rules, word, n_steps);
    for (int i = 0; i < res.size(); i++) {
        str = "";
        cout << tree_to_str(res[i], str) << endl;
        delete_tree(res[i]);
    }
    return 0;
}
