#数据结构
进程到文件系统的关联

```
include/linux/sched.h
struct task_struct {
	...
	struct files_struct *files; //用于存储当前进程打开的file文件指针
	struct fs_struct *fs;       //存储文件系统信息：struct path root, pwd; root目录以及当前工作目录信息
	...
};

include/linux/path.h
struct path {
    struct vfsmount *mnt;
    struct dentry *dentry; 当前目录对应的dentry信息；
};

include/linux/mount.h
在执行mount操作时创建一个这样的数据结构
struct vfsmount {
    struct dentry *mnt_root;    /* root of the mounted tree */
    struct super_block *mnt_sb; /* pointer to superblock */
    int mnt_flags;
};

```

文件系统类型：用来表示一种类型的文件系统以及对应的操作集合

```
include/linux/fs.h
struct file_system_type {
	...
	//重要的函数，不同的fs实现不同的mount函数，在里面初始化super_block，并返回sb对应的root dentry指针
	struct dentry *(*mount) (struct file_system_type *, int,const char *, void *);
	...
}
static struct file_system_type *file_systems; //内核中用来存储所有文件系统类型的列表头指针
```

超级块：一个文件系统实例对应一个超级块

```
include/linux/fs.h
struct super_block {
	...
	const struct super_operations   *s_op;  //SB的操作函数集
	struct dentry       *s_root;            //mount的root路径对应的dentry
	const struct dentry_operations *s_d_op; //默认的dentry操作函数集
	...
};
```

inode: 代表一个文件内容的物理实体
file:代表一个文件的逻辑实体
dentry:文件名信息

```
struct inode {
	...
	const struct inode_operations   *i_op;       //inode对应的操作函数集
	struct address_space            *i_mapping;  //用于把文件内容存储到内存提供机制
	const struct file_operations    *i_fop;      //文件操作函数集
	...
}

struct file {
	...
	const struct file_operations    *f_op;   //一般从inode中继承出来了
	struct address_space    *f_mapping;      //文件内容，并包含一个指向inode的地址
	...
};
include/linux/dcache.h
struct dentry {
	...
	struct inode *d_inode;                    //对应的inode信息
	unsigned char d_iname[DNAME_INLINE_LEN];  //短文件名
	struct qstr d_name;                       //长文件名
	struct super_block *d_sb;                 //目录对应的超级块信息
	const struct dentry_operations *d_op;     //dentry操作集
	
	...
}

```

# 文件系统mount
```
fs/namespace.c
SYSCALL_DEFINE5(mount, xxx) {
	1.根据fs_type_name查找对应的file_system_type结构
	2.调用file_system_type->mount()函数
	3.创建一个vfsmount结构，并将其插入到一个tree结构中
};

具体文件系统的mount（debugfs）
fs/debugfs/inode.c
static struct dentry *debug_mount() {
	1.创建一个SB
	2.填充超级块的信息
		- 设置super_block_operations
		- 为超级块设置创建一个inode，并设置file_operations以及inode_operations
		- 设置dentry的operations
	3.返回fs对应的root地址对应的dentry
}
```


